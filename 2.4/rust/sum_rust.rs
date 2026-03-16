use std::env;
use std::thread;
use std::time::Instant;

fn mix64(mut x: u64) -> u64 {
    x ^= x >> 33;
    x = x.wrapping_mul(0xff51afd7ed558ccd);
    x ^= x >> 33;
    x = x.wrapping_mul(0xc4ceb9fe1a85ec53);
    x ^= x >> 33;
    x
}

fn chunk_sum(start: u64, end: u64) -> u64 {
    let mut acc = 0_u64;
    let mut i = start;
    while i < end {
        acc = acc.wrapping_add(mix64(i));
        i += 1;
    }
    acc
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 4 {
        eprintln!("Usage: {} <seq|threads> <workers> <n>", args[0]);
        std::process::exit(1);
    }

    let mode = &args[1];
    let workers: usize = args[2].parse().unwrap();
    let n: u64 = args[3].parse().unwrap();

    let start = Instant::now();

    let checksum = match mode.as_str() {
        "seq" => chunk_sum(0, n),
        "threads" => {
            let mut handles = Vec::with_capacity(workers);
            let chunk = n / workers as u64;
            let mut cur = 0_u64;

            for i in 0..workers {
                let s = cur;
                let e = if i + 1 == workers { n } else { cur + chunk };
                handles.push(thread::spawn(move || chunk_sum(s, e)));
                cur = e;
            }

            let mut total = 0_u64;
            for h in handles {
                total = total.wrapping_add(h.join().unwrap());
            }
            total
        }
        _ => {
            eprintln!("mode must be seq|threads");
            std::process::exit(1);
        }
    };

    let elapsed_ms = start.elapsed().as_secs_f64() * 1000.0;

    println!("language: Rust");
    println!("mode: {}", mode);
    println!("workers: {}", workers);
    println!("n: {}", n);
    println!("checksum: {}", checksum);
    println!("time_ms: {:.3}", elapsed_ms);
}
