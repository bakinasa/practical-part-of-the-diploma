# Section 2.4 — Concurrency and parallelism

**Goals:** Shared state and race conditions (A); CPU-bound parallelism and scaling (B); async as a separate execution model (C).

**Structure:**
- `c/` — counter_c.c, sum_c.c (Windows threads)
- `rust/` — rust_rejected.rs (must not compile), counter_rust.rs, sum_rust.rs
- `haskell/` — counter_hs.hs, sum_hs.hs (threaded +RTS -N)
- `python/` — counter_py.py (multiprocessing), sum_py.py (seq/threads/processes), async_py.py
- `common/` — run_monitor.py, build_report.py
- `out/` — executables, exp_a_*, exp_b_*, exp_c_* JSON logs, rust_rejected_build.txt
- `report/report.txt` — generated report with tables

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

**Run:** From folder 2.4 run `.\run_2_4.ps1` — builds, runs A/B/C, saves JSON, then builds report.

**Report:** `python common/build_report.py` reads `out/exp_*.json`, writes `report/report.txt` with:
- Rust rejected compile error (if any)
- Table A: shared counter (language, variant, workers, ok_rate, avg_time_ms, peak_rss_mb)
- Table B: parallel reduction (language, mode, workers, checksum, avg_time_ms, speedup, efficiency, peak_rss_mb)
- Table C: async (mode, tasks, delay_ms, avg_time_ms, peak_rss_mb)

**Dependencies:** `pip install psutil`
