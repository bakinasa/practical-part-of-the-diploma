enum Color {
    Red,
    Green,
    Blue,
}

fn to_code(c: Color) -> i32 {
    match c {
        Color::Red => 1,
        Color::Green => 2,
    }
}

fn main() {
    let _ = to_code(Color::Blue);
}