# Section 2.3 — Error detection across languages

**Goal:** Compare how C, Rust, Haskell, and Python detect and report typical errors (type mismatch, null dereference, non-exhaustive patterns, etc.) at compile time and at runtime.

**Structure:**
- `c/` — small C programs with undefined behaviour / UB cases and sanitizer variants.
- `rust/` — Rust examples with type errors and borrow checker diagnostics.
- `haskell/` — Haskell examples (pattern matching, type mismatch).
- `python/` — Python examples (TypeError, None vs value, non-exhaustive logic).
- `Makefile` — builds the C binaries used in this section.
- `run.ps1` — Windows script: builds/runs all experiments, captures logs with redacted paths and exit codes.
- `report.ps1` — generates `logs/report.txt` with system info, compiler versions, optimization flags, log excerpts, and commentary (paths and machine-specific data are anonymized to `<project>`).

**Run (from `2.3/`):**
- `.\run.ps1` — build and run all language variants, write logs into `logs/`.
- `.\report.ps1` — summarize all logs into `logs/report.txt` (already in English, with paths and host-specific details redacted).

Logs in `2.3/logs/` are safe to commit: user-specific paths are replaced by `<project>`, and no computer name or username is emitted.*** End Patch***`"`
