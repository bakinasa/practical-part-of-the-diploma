# Section 2.1 — Compilation and interpretation as materialization of semantics

**Local goal:** Empirically show that compilation and interpretation are not neutral technical stages but mechanisms that materialize the formal semantics of a language.

**Research questions:**
1. What intermediate forms appear between source and execution?
2. How do different languages reflect the same computational step at IR, assembly, or bytecode level?
3. What semantic differences are visible at translation time, before execution?

**Structure:**
- **Part A (Dijkstra):** Full case — artifact sizes, comparison of executable forms. **Sources from `../1.5`** (no duplication).
- **Part B (micro):** Relaxation step only — IR, assembly, inlining, one semantic operation across languages.

**Outputs:** `out/` (artifacts), `report/` (tables, excerpts). Run `.\run.ps1` to build all and generate the report.
