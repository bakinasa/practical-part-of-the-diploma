fn main() {
    let mut v = vec![1, 2, 3];

    let r1 = &mut v;
    let r2 = &mut v;

    println!("{:?} {:?}", r1, r2);
}