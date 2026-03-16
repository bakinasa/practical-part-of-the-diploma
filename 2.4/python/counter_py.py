import multiprocessing as mp
import sys
import time


def worker_race(value, iters: int):
    for i in range(iters):
        x = value.value
        if (i & 1023) == 0:
            time.sleep(0)
        value.value = x + 1


def worker_lock(value, lock, iters: int):
    for _ in range(iters):
        with lock:
            value.value += 1


def main():
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <race|lock> <workers> <iters>")
        sys.exit(1)

    variant = sys.argv[1]
    workers = int(sys.argv[2])
    iters = int(sys.argv[3])

    mp.set_start_method("spawn", force=True)

    if variant == "race":
        value = mp.Value("q", 0, lock=False)
        lock = None
        target = worker_race
    elif variant == "lock":
        value = mp.Value("q", 0, lock=False)
        lock = mp.Lock()
        target = worker_lock
    else:
        raise ValueError("variant must be race|lock")

    procs = []
    t0 = time.perf_counter()

    for _ in range(workers):
        if variant == "race":
            p = mp.Process(target=target, args=(value, iters))
        else:
            p = mp.Process(target=target, args=(value, lock, iters))
        p.start()
        procs.append(p)

    for p in procs:
        p.join()

    elapsed_ms = (time.perf_counter() - t0) * 1000.0
    expected = workers * iters
    observed = value.value

    print("language: Python")
    print(f"variant: {variant}")
    print(f"workers: {workers}")
    print(f"iterations_per_worker: {iters}")
    print(f"expected: {expected}")
    print(f"observed: {observed}")
    print(f"ok: {1 if expected == observed else 0}")
    print(f"time_ms: {elapsed_ms:.3f}")


if __name__ == "__main__":
    main()
