/*
 * Dijkstra: shortest paths from source. Reads graph from file.
 * Format: first line "n m source", then m lines "u v weight".
 * Runs 50 times and prints avg_time_ms and checksum (sum of finite distances).
 */
use std::collections::BinaryHeap;
use std::cmp::Ordering;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::time::Instant;

const RUNS: u32 = 50;

// Ребро графа: куда ведёт (to) и каков вес (w).
#[derive(Clone, Copy)]
struct Edge { to: usize, w: f64 }

// Состояние для очереди с приоритетом: вершина и текущее расстояние до неё.
// Реализуем сравнения так, чтобы BinaryHeap стал "минимальной" кучей по dist.
#[derive(PartialEq)]
struct State { dist: f64, v: usize }
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

// Чтение графа из файла и построение списка смежности.
fn parse_graph(path: &str) -> Result<(Vec<Vec<Edge>>, usize), Box<dyn std::error::Error>> {
    let f = File::open(path)?;
    let mut lines = BufReader::new(f).lines();
    // Первая строка: n m source
    let first = lines.next().ok_or("empty file")??;
    let parts: Vec<&str> = first.split_whitespace().collect();
    let n: usize = parts[0].parse()?;
    let m: usize = parts[1].parse()?;
    let source: usize = parts[2].parse()?;
    // adj[u] — список рёбер исходящих из вершины u
    let mut adj: Vec<Vec<Edge>> = vec![Vec::new(); n];
    // Берём только m строк с рёбрами и добавляем каждое в список смежности.
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

// Алгоритм Дейкстры из вершины source.
// Возвращает сумму всех конечных расстояний (checksum).
fn dijkstra(adj: &[Vec<Edge>], source: usize) -> f64 {
    let n = adj.len();
    // dist[v] — кратчайшее известное расстояние от source до v
    let mut dist: Vec<f64> = vec![f64::INFINITY; n];
    dist[source] = 0.0;
    // Очередь с приоритетом (минимальная куча по dist)
    let mut heap: BinaryHeap<State> = BinaryHeap::new();
    heap.push(State { dist: 0.0, v: source });
    // Основной цикл: достаём вершину с минимальным расстоянием
    // и релаксируем все исходящие из неё рёбра.
    while let Some(State { dist: du, v: u }) = heap.pop() {
        // Если в куче оказалось устаревшее расстояние — пропускаем
        if du > dist[u] {
            continue;
        }
        for e in &adj[u] {
            let alt = du + e.w;
            if alt < dist[e.to] {
                dist[e.to] = alt;
                heap.push(State { dist: alt, v: e.to });
            }
        }
    }
    // Складываем только конечные значения — это checksum.
    dist.iter().filter(|d| d.is_finite()).sum()
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let path = std::env::args().nth(1).unwrap_or_else(|| "graph.txt".to_string());
    let (adj, source) = parse_graph(&path)?;
    let start = Instant::now();
    let mut total_checksum = 0.0;
    for _ in 0..RUNS {
        total_checksum += dijkstra(&adj, source);
    }
    let elapsed = start.elapsed();
    let avg_ms = elapsed.as_secs_f64() * 1000.0 / RUNS as f64;
    println!("avg_time_ms: {:.2}", avg_ms);
    println!("checksum: {:.6}", total_checksum);
    println!("runs: {}", RUNS);
    Ok(())
}
