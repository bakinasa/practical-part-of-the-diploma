import time

ITERS = 100_000_000


def step(old: float, du: float, w: float) -> float:
    alt = du + w
    return alt if alt < old else old


def main():
    acc = 0.0
    old = 1_000_000.0
    du = 1.0
    w = 0.5

    t0 = time.perf_counter()
    for _ in range(ITERS):
        old = step(old, du, w)
        du += 0.000001
        w += 0.000002
        acc += old
        if du > 1000.0:
            du = 1.0
        if w > 1000.0:
            w = 0.5
    ms = (time.perf_counter() - t0) * 1000.0

    print(f"time_ms: {ms:.2f}")
    print(f"checksum: {acc:.6f}")
    print(f"iters: {ITERS}")


if __name__ == "__main__":
    main()
