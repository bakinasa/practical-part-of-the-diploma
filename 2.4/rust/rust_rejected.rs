use std::cell::RefCell;
use std::rc::Rc;
use std::thread;

fn main() {
    let counter = Rc::new(RefCell::new(0_u64));
    let mut handles = Vec::new();

    for _ in 0..4 {
        let c = Rc::clone(&counter);
        handles.push(thread::spawn(move || {
            for _ in 0..100_000 {
                *c.borrow_mut() += 1;
            }
        }));
    }

    for h in handles {
        h.join().unwrap();
    }

    println!("{}", *counter.borrow());
}
