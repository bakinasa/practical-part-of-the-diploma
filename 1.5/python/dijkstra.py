"""
Dijkstra: shortest paths from source. Reads graph from file.
Format: first line "n m source", then m lines "u v weight".
Runs 50 times and prints avg_time_ms and checksum (sum of finite distances).
"""
import heapq
import sys
import time

RUNS = 50


def parse_graph(path: str):
    with open(path) as f:
        line = f.readline()
        n, m, source = map(int, line.split())
        adj = [[] for _ in range(n)]
        for _ in range(m):
            u, v, w = f.readline().split()
            u, v, w = int(u), int(v), float(w)
            adj[u].append((v, w))
    return adj, source


def dijkstra(adj, source):
    n = len(adj)
    dist = [float("inf")] * n
    dist[source] = 0.0
    heap = [(0.0, source)]
    while heap:
        du, u = heapq.heappop(heap)
        if du > dist[u]:
            continue
        for v, w in adj[u]:
            alt = du + w
            if alt < dist[v]:
                dist[v] = alt
                heapq.heappush(heap, (alt, v))
    return sum(d for d in dist if d != float("inf"))


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "graph.txt"
    adj, source = parse_graph(path)
    t0 = time.perf_counter()
    total_checksum = 0.0
    for _ in range(RUNS):
        total_checksum += dijkstra(adj, source)
    elapsed = time.perf_counter() - t0
    avg_ms = (elapsed * 1000.0) / RUNS
    print(f"avg_time_ms: {avg_ms:.2f}")
    print(f"checksum: {total_checksum:.6f}")
    print(f"runs: {RUNS}")


if __name__ == "__main__":
    main()
