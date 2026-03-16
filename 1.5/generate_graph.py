"""
Generate a directed weighted graph: n vertices, m edges.
- Uniqueness by (u, v) only (no parallel edges).
- Ensures reachability: first add chain 0->1->2->...->min(n-1, n_chain),
  then fill with random (u, v) until m edges.
Format: first line 'n m source', then m lines 'u v weight' (0-indexed).
"""
import random
import sys

def main():
    n = 100_000
    m = 500_000
    source = 0
    seed = 42
    random.seed(seed)
    out_path = "graph.txt"
    if len(sys.argv) > 1:
        out_path = sys.argv[1]

    edges_set = set()  # (u, v) only for uniqueness

    # Chain from source for reachability: 0 -> 1 -> 2 -> ... -> min(n-1, chain_len)
    chain_len = min(n - 1, 5000)
    for i in range(chain_len):
        edges_set.add((i, i + 1))

    # Fill with random (u, v), u != v, until we have m edges
    while len(edges_set) < m:
        u = random.randint(0, n - 1)
        v = random.randint(0, n - 1)
        if u != v:
            edges_set.add((u, v))

    # Convert to list and assign random weights
    edges = [(u, v, round(random.uniform(0.1, 100.0), 2)) for u, v in edges_set]

    with open(out_path, "w") as f:
        f.write(f"{n} {len(edges)} {source}\n")
        for u, v, w in edges:
            f.write(f"{u} {v} {w}\n")
    print(f"Written {n} vertices, {len(edges)} edges to {out_path}")

if __name__ == "__main__":
    main()
