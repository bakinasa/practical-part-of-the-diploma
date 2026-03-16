import concurrent.futures as cf
import sys
import time


def mix64(x: int) -> int:
    x ^= x >> 33
    x = (x * 0xFF51AFD7ED558CCD) & 0xFFFFFFFFFFFFFFFF
    x ^= x >> 33
    x = (x * 0xC4CEB9FE1A85EC53) & 0xFFFFFFFFFFFFFFFF
    x ^= x >> 33
    return x


def chunk_sum(start: int, end: int) -> int:
    acc = 0
    for i in range(start, end):
        acc = (acc + mix64(i)) & 0xFFFFFFFFFFFFFFFF
    return acc


def chunk_sum_star(args):
    return chunk_sum(*args)


def split_ranges(workers: int, n: int):
    chunk = n // workers
    cur = 0
    ranges = []
    for i in range(workers):
        nxt = n if i == workers - 1 else cur + chunk
        ranges.append((cur, nxt))
        cur = nxt
    return ranges


def main():
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <seq|threads|processes> <workers> <n>")
        sys.exit(1)

    mode = sys.argv[1]
    workers = int(sys.argv[2])
    n = int(sys.argv[3])

    t0 = time.perf_counter()

    if mode == "seq":
        checksum = chunk_sum(0, n)
    elif mode == "threads":
        ranges = split_ranges(workers, n)
        with cf.ThreadPoolExecutor(max_workers=workers) as ex:
            parts = list(ex.map(lambda p: chunk_sum(*p), ranges))
        checksum = sum(parts) & 0xFFFFFFFFFFFFFFFF
    elif mode == "processes":
        ranges = split_ranges(workers, n)
        with cf.ProcessPoolExecutor(max_workers=workers) as ex:
            parts = list(ex.map(chunk_sum_star, ranges))
        checksum = sum(parts) & 0xFFFFFFFFFFFFFFFF
    else:
        raise ValueError("mode must be seq|threads|processes")

    elapsed_ms = (time.perf_counter() - t0) * 1000.0

    print("language: Python")
    print(f"mode: {mode}")
    print(f"workers: {workers}")
    print(f"n: {n}")
    print(f"checksum: {checksum}")
    print(f"time_ms: {elapsed_ms:.3f}")


if __name__ == "__main__":
    main()
