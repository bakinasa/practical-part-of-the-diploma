fn inc(x: i32) -> i32 {
    x + 1
}

fn main() {
    let maybe: Option<i32> = None;
    let x: i32 = maybe;
    println!("{}", inc(x));
}