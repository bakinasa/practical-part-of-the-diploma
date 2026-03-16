use std::time::Instant;

const ITERS: u64 = 100_000_000;

#[inline(always)]
fn step(old: f64, du: f64, w: f64) -> f64 {
    let alt = du + w;
    if alt < old {
        alt
    } else {
        old
    }
}

fn main() {
    let mut acc = 0.0f64;
    let mut old = 1_000_000.0f64;
    let mut du = 1.0f64;
    let mut w = 0.5f64;

    let t0 = Instant::now();
    for _ in 0..ITERS {
        old = step(old, du, w);
        du += 0.000001;
        w += 0.000002;
        acc += old;
        if du > 1000.0 {
            du = 1.0;
        }
        if w > 1000.0 {
            w = 0.5;
        }
    }
    let ms = t0.elapsed().as_secs_f64() * 1000.0;

    println!("time_ms: {:.2}", ms);
    println!("checksum: {:.6}", acc);
    println!("iters: {}", ITERS);
}
