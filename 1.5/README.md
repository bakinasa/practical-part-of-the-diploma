# Section 1.5 — Dijkstra metrics

Formal setting: graph G=(V,E), weight w: E -> R>=0, source s. Compute d: V -> R>=0 ∪ {∞} (shortest path lengths from s).

Implementations: C, Rust, Haskell, Python. Same algorithm (priority queue / relaxation), same input graph (10k vertices, 50k edges).

- Generate graph: `python generate_graph.py`
- Run all and get report: `.\run.ps1` (from 1.5 folder)
