import asyncio
import concurrent.futures as cf
import sys
import time


def blocking_task(delay_ms: int):
    time.sleep(delay_ms / 1000.0)
    return 1


async def async_task(delay_ms: int):
    await asyncio.sleep(delay_ms / 1000.0)
    return 1


def run_seq(tasks: int, delay_ms: int) -> int:
    total = 0
    for _ in range(tasks):
        total += blocking_task(delay_ms)
    return total


def run_threads(tasks: int, delay_ms: int) -> int:
    with cf.ThreadPoolExecutor() as ex:
        futures = [ex.submit(blocking_task, delay_ms) for _ in range(tasks)]
        return sum(f.result() for f in futures)


async def run_async(tasks: int, delay_ms: int) -> int:
    results = await asyncio.gather(
        *(async_task(delay_ms) for _ in range(tasks))
    )
    return sum(results)


def main():
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <seq|threads|async> <tasks> <delay_ms>")
        sys.exit(1)

    mode = sys.argv[1]
    tasks = int(sys.argv[2])
    delay_ms = int(sys.argv[3])

    t0 = time.perf_counter()

    if mode == "seq":
        checksum = run_seq(tasks, delay_ms)
    elif mode == "threads":
        checksum = run_threads(tasks, delay_ms)
    elif mode == "async":
        checksum = asyncio.run(run_async(tasks, delay_ms))
    else:
        raise ValueError("mode must be seq|threads|async")

    elapsed_ms = (time.perf_counter() - t0) * 1000.0

    print("language: Python")
    print(f"mode: {mode}")
    print(f"tasks: {tasks}")
    print(f"delay_ms: {delay_ms}")
    print(f"checksum: {checksum}")
    print(f"time_ms: {elapsed_ms:.3f}")


if __name__ == "__main__":
    main()
