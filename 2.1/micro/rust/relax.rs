fn relax(old: f64, du: f64, w: f64) -> f64 {
    let alt = du + w;
    if alt < old {
        alt
    } else {
        old
    }
}

#[no_mangle]
pub fn step(old: f64, du: f64, w: f64) -> f64 {
    relax(old, du, w)
}

fn main() {
    println!("{:.2}", step(10.0, 3.0, 4.0));
}
