use std::alloc::{GlobalAlloc, Layout, System};
use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::sync::atomic::{AtomicU64, AtomicUsize, Ordering as AtomicOrdering};
use std::time::Instant;

const RUNS: u32 = 50;
const PHASE_OFF: usize = 0;
const PHASE_PARSE: usize = 1;
const PHASE_ALGO: usize = 2;

#[derive(Default)]
struct Snapshot {
    allocs: u64,
    deallocs: u64,
    reallocs: u64,
    total_bytes: u64,
    current_bytes: u64,
    peak_bytes: u64,
}

struct PhaseStats {
    allocs: AtomicU64,
    deallocs: AtomicU64,
    reallocs: AtomicU64,
    total_bytes: AtomicU64,
    current_bytes: AtomicU64,
    peak_bytes: AtomicU64,
}

impl PhaseStats {
    const fn new() -> Self {
        Self {
            allocs: AtomicU64::new(0),
            deallocs: AtomicU64::new(0),
            reallocs: AtomicU64::new(0),
            total_bytes: AtomicU64::new(0),
            current_bytes: AtomicU64::new(0),
            peak_bytes: AtomicU64::new(0),
        }
    }

    fn snapshot(&self) -> Snapshot {
        Snapshot {
            allocs: self.allocs.load(AtomicOrdering::Relaxed),
            deallocs: self.deallocs.load(AtomicOrdering::Relaxed),
            reallocs: self.reallocs.load(AtomicOrdering::Relaxed),
            total_bytes: self.total_bytes.load(AtomicOrdering::Relaxed),
            current_bytes: self.current_bytes.load(AtomicOrdering::Relaxed),
            peak_bytes: self.peak_bytes.load(AtomicOrdering::Relaxed),
        }
    }
}

static PHASE: AtomicUsize = AtomicUsize::new(PHASE_OFF);
static PARSE_STATS: PhaseStats = PhaseStats::new();
static ALGO_STATS: PhaseStats = PhaseStats::new();

fn active_stats(phase: usize) -> Option<&'static PhaseStats> {
    match phase {
        PHASE_PARSE => Some(&PARSE_STATS),
        PHASE_ALGO => Some(&ALGO_STATS),
        _ => None,
    }
}

fn update_peak(peak: &AtomicU64, current: u64) {
    let mut prev = peak.load(AtomicOrdering::Relaxed);
    while current > prev {
        match peak.compare_exchange_weak(
            prev,
            current,
            AtomicOrdering::Relaxed,
            AtomicOrdering::Relaxed,
        ) {
            Ok(_) => break,
            Err(next) => prev = next,
        }
    }
}

fn note_alloc(stats: &PhaseStats, size: u64) {
    stats.allocs.fetch_add(1, AtomicOrdering::Relaxed);
    stats.total_bytes.fetch_add(size, AtomicOrdering::Relaxed);
    let current = stats.current_bytes.fetch_add(size, AtomicOrdering::Relaxed) + size;
    update_peak(&stats.peak_bytes, current);
}

fn note_dealloc(stats: &PhaseStats, size: u64) {
    stats.deallocs.fetch_add(1, AtomicOrdering::Relaxed);
    let _ = stats.current_bytes.fetch_update(
        AtomicOrdering::Relaxed,
        AtomicOrdering::Relaxed,
        |cur| Some(cur.saturating_sub(size)),
    );
}

fn note_realloc(stats: &PhaseStats, old_size: u64, new_size: u64) {
    stats.reallocs.fetch_add(1, AtomicOrdering::Relaxed);
    if new_size > old_size {
        let delta = new_size - old_size;
        stats.total_bytes.fetch_add(delta, AtomicOrdering::Relaxed);
        let current = stats.current_bytes.fetch_add(delta, AtomicOrdering::Relaxed) + delta;
        update_peak(&stats.peak_bytes, current);
    } else if old_size > new_size {
        let delta = old_size - new_size;
        let _ = stats.current_bytes.fetch_update(
            AtomicOrdering::Relaxed,
            AtomicOrdering::Relaxed,
            |cur| Some(cur.saturating_sub(delta)),
        );
    }
}

struct TrackingAllocator;

#[global_allocator]
static GLOBAL: TrackingAllocator = TrackingAllocator;

unsafe impl GlobalAlloc for TrackingAllocator {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        let p = System.alloc(layout);
        if !p.is_null() {
            if let Some(stats) = active_stats(PHASE.load(AtomicOrdering::Relaxed)) {
                note_alloc(stats, layout.size() as u64);
            }
        }
        p
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        if let Some(stats) = active_stats(PHASE.load(AtomicOrdering::Relaxed)) {
            note_dealloc(stats, layout.size() as u64);
        }
        System.dealloc(ptr, layout);
    }

    unsafe fn realloc(
        &self,
        ptr: *mut u8,
        layout: Layout,
        new_size: usize,
    ) -> *mut u8 {
        let p = System.realloc(ptr, layout, new_size);
        if !p.is_null() {
            if let Some(stats) = active_stats(PHASE.load(AtomicOrdering::Relaxed)) {
                note_realloc(stats, layout.size() as u64, new_size as u64);
            }
        }
        p
    }
}

#[derive(Clone, Copy)]
struct Edge {
    to: usize,
    w: f64,
}

#[derive(PartialEq)]
struct State {
    dist: f64,
    v: usize,
}

impl Eq for State {}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        other.dist.partial_cmp(&self.dist)
    }
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        self.partial_cmp(other).unwrap_or(Ordering::Equal)
    }
}

fn parse_graph(
    path: &str,
) -> Result<(Vec<Vec<Edge>>, usize), Box<dyn std::error::Error>> {
    let f = File::open(path)?;
    let mut lines = BufReader::new(f).lines();

    let first = lines.next().ok_or("empty file")??;
    let parts: Vec<&str> = first.split_whitespace().collect();
    let n: usize = parts[0].parse()?;
    let m: usize = parts[1].parse()?;
    let source: usize = parts[2].parse()?;

    let mut adj: Vec<Vec<Edge>> = vec![Vec::new(); n];

    for line in lines.take(m) {
        let s = line?;
        let p: Vec<&str> = s.split_whitespace().collect();
        let u: usize = p[0].parse()?;
        let v: usize = p[1].parse()?;
        let w: f64 = p[2].parse()?;
        adj[u].push(Edge { to: v, w });
    }

    Ok((adj, source))
}

fn dijkstra(adj: &[Vec<Edge>], source: usize) -> f64 {
    let n = adj.len();
    let mut dist: Vec<f64> = vec![f64::INFINITY; n];
    dist[source] = 0.0;

    let mut heap: BinaryHeap<State> = BinaryHeap::new();
    heap.push(State {
        dist: 0.0,
        v: source,
    });

    while let Some(State { dist: du, v: u }) = heap.pop() {
        if du > dist[u] {
            continue;
        }

        for e in &adj[u] {
            let alt = du + e.w;
            if alt < dist[e.to] {
                dist[e.to] = alt;
                heap.push(State {
                    dist: alt,
                    v: e.to,
                });
            }
        }
    }

    dist.iter().filter(|d| d.is_finite()).sum()
}

fn print_stats(prefix: &str, s: &PhaseStats) {
    let x = s.snapshot();
    println!("{}_alloc_calls: {}", prefix, x.allocs);
    println!("{}_dealloc_calls: {}", prefix, x.deallocs);
    println!("{}_realloc_calls: {}", prefix, x.reallocs);
    println!("{}_total_bytes: {}", prefix, x.total_bytes);
    println!("{}_current_bytes: {}", prefix, x.current_bytes);
    println!("{}_peak_bytes: {}", prefix, x.peak_bytes);
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let path = std::env::args()
        .nth(1)
        .unwrap_or_else(|| "graph.txt".to_string());

    let t0 = Instant::now();
    PHASE.store(PHASE_PARSE, AtomicOrdering::Relaxed);
    let (adj, source) = parse_graph(&path)?;
    PHASE.store(PHASE_OFF, AtomicOrdering::Relaxed);
    let parse_ms = t0.elapsed().as_secs_f64() * 1000.0;

    let t1 = Instant::now();
    PHASE.store(PHASE_ALGO, AtomicOrdering::Relaxed);
    let mut total_checksum = 0.0;
    for _ in 0..RUNS {
        total_checksum += dijkstra(&adj, source);
    }
    PHASE.store(PHASE_OFF, AtomicOrdering::Relaxed);
    let algo_avg_ms = t1.elapsed().as_secs_f64() * 1000.0 / RUNS as f64;

    println!("parse_ms: {:.2}", parse_ms);
    println!("algo_avg_ms: {:.2}", algo_avg_ms);
    println!("checksum: {:.6}", total_checksum);
    println!("runs: {}", RUNS);

    print_stats("parse", &PARSE_STATS);
    print_stats("algo", &ALGO_STATS);

    Ok(())
}
