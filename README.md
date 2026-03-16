# Diploma practice

Practical materials for the diploma. Each section has its own `README.md`, a run script, and (where appropriate) a report generator.

- **1.5 — Dijkstra metrics**  
  Dijkstra implementations in C, Rust, Haskell, Python on a common random graph. Measures wall time, basic memory behaviour, and checksum equivalence.  
  Run from `1.5/`: `.\run.ps1`.

- **2.1 — Compilation and interpretation as materialization of semantics**  
  Uses Dijkstra (from `1.5`) and a small `relax` micro-example to collect IR, assembly, Core/bytecode, and executable artifacts in C, Rust, Haskell, Python. Shows how compilation / interpretation materialize the language’s semantic model.  
  Run from `2.1/`: `.\run.ps1` (builds artifacts and writes `2.1/report/report.txt` with tables and excerpts).

- **2.2 — Execution model and architectural correspondence**  
  Instrumented Dijkstra + `relax_loop` microbenchmark in four languages. External monitor (`run_monitor.py`) records wall time and peak RSS; internal instrumentation records allocations / RTS / tracemalloc stats.  
  Run from `2.2/`: `.\run_2_2.ps1` (builds, runs all variants, and generates `2.2/report/report.txt`).

- **2.3 — Error detection across languages**  
  Small error-focused examples in C, Rust, Haskell, Python (type errors, null dereference, non-exhaustive logic, sanitizers). Shows what is caught at compile time vs runtime and how diagnostics differ.  
  Run from `2.3/`: `.\run.ps1` (experiments) then `.\report.ps1` (aggregated `2.3/logs/report.txt`).

- **2.4 — Concurrency and parallelism**  
  Three experiments: A) shared counter (races vs mutex/atomic, compile-time rejection in Rust, IORef/MVar in Haskell, multiprocessing in Python); B) parallel reduction (CPU-bound scaling and speedup/efficiency); C) async timer swarm (seq vs threads vs async).  
  Run from `2.4/`: `.\run_2_4.ps1` (JSON metrics in `2.4/out/`, summary in `2.4/report/report.txt`).

User-specific paths and machine names are redacted in generated reports (`<project>`), and heavy/low-level artifacts in `*/out/` are ignored via `.gitignore` to keep the repository clean and free of confidential information.
