# Section 2.2 — Execution model and architectural correspondence

**Goal:** Show that language differences persist at runtime; same algorithm lives differently in memory and runtime; type/paradigm affect allocations; runtime is part of the language's technical existence.

**Layer A (required):** Dijkstra — time, peak RSS, internal allocations, role of runtime.  
**Layer B (supporting):** relax_loop microbenchmark — isolates execution-model overhead.

**Structure:**
- `common/run_monitor.py` — runs a command, outputs one JSON: wall_ms, peak_rss_mb, exit_code, stdout, stderr.
- `c/` — dijkstra_22.c, relax_loop_22.c
- `rust/` — dijkstra_22.rs, relax_loop_22.rs
- `haskell/` — Dijkstra22.hs, RelaxLoop22.hs
- `python/` — dijkstra_22.py, relax_loop_22.py
- `out/` — executables and JSON logs (dijkstra_*_run1..3.json, relax_loop_*_run1..3.json)

**Build (from repo root or 2.2):**
```text
gcc -O2 2.2/c/dijkstra_22.c -o 2.2/out/dijkstra_c_22.exe
gcc -O2 2.2/c/relax_loop_22.c -o 2.2/out/relax_loop_c_22.exe
rustc 2.2/rust/dijkstra_22.rs -C opt-level=3 -o 2.2/out/dijkstra_rust_22.exe
rustc 2.2/rust/relax_loop_22.rs -C opt-level=3 -o 2.2/out/relax_loop_rust_22.exe
ghc -O2 -rtsopts 2.2/haskell/Dijkstra22.hs -o 2.2/out/dijkstra_hs_22.exe
ghc -O2 -rtsopts 2.2/haskell/RelaxLoop22.hs -o 2.2/out/relax_loop_hs_22.exe
```

**Run (use same graph as 1.5):** Copy or generate `graph.txt` in 2.2, then:
```text
python 2.2/common/run_monitor.py 2.2/out/dijkstra_c_22.exe graph.txt
python 2.2/common/run_monitor.py 2.2/out/dijkstra_hs_22.exe graph.txt +RTS -s
python 2.2/common/run_monitor.py python 2.2/python/dijkstra_22.py graph.txt
```
(Similarly for Rust and for relax_loop without graph.txt.)

**Automation:** From folder 2.2 run `.\run_2_2.ps1` — builds all, runs each variant 3 times, saves JSON to `out/`, then builds the report.

**Report:** `python common/build_report.py` (or run after `run_2_2.ps1`) reads all `out/*.json`, extracts metrics and language-specific stats (C alloc/free, Rust alloc/dealloc/realloc, Python tracemalloc, Haskell RTS), and writes `report/report.txt` with summary tables, detailed per-run output, errors (if any), and missing-metrics list. Supports UTF-8 BOM in JSON (e.g. from PowerShell Out-File).

**Dependencies:** `python -m pip install psutil` for run_monitor.py.
