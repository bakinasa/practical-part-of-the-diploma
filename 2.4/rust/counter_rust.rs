use std::env;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Instant;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 4 {
        eprintln!("Usage: {} <mutex|atomic> <workers> <iters>", args[0]);
        std::process::exit(1);
    }

    let variant = &args[1];
    let workers: usize = args[2].parse().unwrap();
    let iters: u64 = args[3].parse().unwrap();

    let start = Instant::now();

    let observed = match variant.as_str() {
        "mutex" => {
            let counter = Arc::new(Mutex::new(0_u64));
            let mut handles = Vec::with_capacity(workers);

            for _ in 0..workers {
                let c = Arc::clone(&counter);
                handles.push(thread::spawn(move || {
                    for _ in 0..iters {
                        let mut guard = c.lock().unwrap();
                        *guard += 1;
                    }
                }));
            }

            for h in handles {
                h.join().unwrap();
            }

            let val = *counter.lock().unwrap();
            val
        }
        "atomic" => {
            let counter = Arc::new(AtomicU64::new(0));
            let mut handles = Vec::with_capacity(workers);

            for _ in 0..workers {
                let c = Arc::clone(&counter);
                handles.push(thread::spawn(move || {
                    for _ in 0..iters {
                        c.fetch_add(1, Ordering::Relaxed);
                    }
                }));
            }

            for h in handles {
                h.join().unwrap();
            }

            counter.load(Ordering::Relaxed)
        }
        _ => {
            eprintln!("Unknown variant: {}", variant);
            std::process::exit(1);
        }
    };

    let elapsed = start.elapsed().as_secs_f64() * 1000.0;
    let expected = workers as u64 * iters;

    println!("language: Rust");
    println!("variant: {}", variant);
    println!("workers: {}", workers);
    println!("iterations_per_worker: {}", iters);
    println!("expected: {}", expected);
    println!("observed: {}", observed);
    println!("ok: {}", if expected == observed { 1 } else { 0 });
    println!("time_ms: {:.3}", elapsed);
}
