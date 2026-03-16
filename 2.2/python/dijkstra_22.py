import heapq
import sys
import time
import tracemalloc

RUNS = 50


def parse_graph(path: str):
    with open(path, "r", encoding="utf-8") as f:
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

    tracemalloc.start()

    t0 = time.perf_counter()
    adj, source = parse_graph(path)
    parse_ms = (time.perf_counter() - t0) * 1000.0
    _, parse_peak = tracemalloc.get_traced_memory()
    try:
        tracemalloc.reset_peak()
    except AttributeError:
        # Python < 3.9: restart tracemalloc to measure algo phase separately
        tracemalloc.stop()
        tracemalloc.start()

    t1 = time.perf_counter()
    total_checksum = 0.0
    for _ in range(RUNS):
        total_checksum += dijkstra(adj, source)
    algo_avg_ms = ((time.perf_counter() - t1) * 1000.0) / RUNS
    _, algo_peak = tracemalloc.get_traced_memory()

    print(f"parse_ms: {parse_ms:.2f}")
    print(f"algo_avg_ms: {algo_avg_ms:.2f}")
    print(f"checksum: {total_checksum:.6f}")
    print(f"runs: {RUNS}")
    print(f"parse_peak_bytes: {parse_peak}")
    print(f"algo_peak_bytes: {algo_peak}")


if __name__ == "__main__":
    main()
