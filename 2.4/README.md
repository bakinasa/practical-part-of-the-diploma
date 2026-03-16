# Section 2.4 — Concurrency and parallelism

**Goals:** Show how language and runtime shape parallel execution:
- Experiment A (shared counter): where races are possible, how safety is enforced (type system vs discipline), and the cost of mutex/atomic.
- Experiment B (parallel reduction): how CPU-bound work scales with threads/processes across languages.
- Experiment C (async swarm): async as a separate execution model for many waiting tasks rather than CPU speedup.

**Structure:**
- `c/` — `counter_c.c`, `sum_c.c` (Windows threads for shared state and reduction).
- `rust/` — `rust_rejected.rs` (must not compile: `Rc<RefCell<_>>` not `Send`), `counter_rust.rs`, `sum_rust.rs`.
- `haskell/` — `counter_hs.hs`, `sum_hs.hs` (threaded, `+RTS -N`).
- `python/` — `counter_py.py` (multiprocessing counter), `sum_py.py` (seq/threads/processes), `async_py.py` (seq/threads/async).
- `common/` — `run_monitor.py` (wall_ms, peak_rss_mb, stdout, stderr), `build_report.py`.
- `out/` — executables, `exp_a_*`, `exp_b_*`, `exp_c_*` JSON logs, `rust_rejected_build.txt`.
- `report/report.txt` — generated report with tables and Rust compile error for the rejected example.

**Build (from 2.4):**
```text
gcc -O2 -std=c17 -Wall -Wextra -o out/counter_c.exe c/counter_c.c
gcc -O2 -std=c17 -Wall -Wextra -o out/sum_c.exe c/sum_c.c
rustc rust/rust_rejected.rs   (expect failure; log to out/rust_rejected_build.txt)
rustc -O rust/counter_rust.rs -o out/counter_rust.exe
rustc -O rust/sum_rust.rs -o out/sum_rust.exe
ghc -O2 -threaded -rtsopts haskell/counter_hs.hs -o out/counter_hs.exe
ghc -O2 -threaded -rtsopts haskell/sum_hs.hs -o out/sum_hs.exe
```

**Run:** From folder `2.4` run `.\run_2_4.ps1` — builds all binaries, runs:
- **A (shared counter):** C (race/mutex/atomic), Rust (mutex/atomic), Haskell (race/atomic/mvar), Python (race/lock) for several worker counts and repetitions.
- **B (parallel reduction):** C/Rust/Haskell/Python, `seq` vs `threads`/`par`/`processes`, workers ∈ {1,2,4,8}, common `n`.
- **C (async swarm):** Python `seq` / `threads` / `async` for many tasks with fixed delay.

The script saves all monitor JSON to `out/` and then calls `python common/build_report.py`.

**Report:** `python common/build_report.py` reads `out/exp_*.json`, writes `report/report.txt` with:
- Rust rejected compile error (if any) to document forbidden shared-state pattern.
- Table A: shared counter — language, variant, workers, iterations, expected/observed, `ok` rate, `avg_time_ms`, `peak_rss_mb`.
- Table B: parallel reduction — language, mode, workers, checksum, `avg_time_ms`, speedup `T1/Tp`, efficiency `T1/(p·Tp)`, `peak_rss_mb`.
- Table C: async swarm — mode (`seq`/`threads`/`async`), tasks, `delay_ms`, checksum, `avg_time_ms`, `peak_rss_mb`.

**Dependencies:** `pip install psutil` (for `run_monitor.py` and `build_report.py`).
