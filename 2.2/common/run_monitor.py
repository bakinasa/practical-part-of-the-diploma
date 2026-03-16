"""
Run a command under monitoring: wall time, peak RSS, stdout/stderr.
Outputs a single JSON object with all metrics.
Usage: python run_monitor.py <command> [args...]
"""
import json
import subprocess
import sys
import time

import psutil


def total_rss(proc: psutil.Process) -> int:
    rss = 0
    try:
        rss += proc.memory_info().rss
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        return 0

    try:
        for child in proc.children(recursive=True):
            try:
                rss += child.memory_info().rss
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        pass

    return rss


def main() -> int:
    if len(sys.argv) < 2:
        print(
            "Usage: python run_monitor.py <command> [args...]",
            file=sys.stderr,
        )
        return 1

    cmd = sys.argv[1:]

    t0 = time.perf_counter()
    p = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
    )

    peak_rss = 0
    samples = 0

    try:
        proc = psutil.Process(p.pid)
    except psutil.NoSuchProcess:
        proc = None

    while p.poll() is None:
        if proc is not None:
            peak_rss = max(peak_rss, total_rss(proc))
            samples += 1
        time.sleep(0.01)

    stdout, stderr = p.communicate()
    wall_ms = (time.perf_counter() - t0) * 1000.0

    if proc is not None:
        peak_rss = max(peak_rss, total_rss(proc))

    result = {
        "command": cmd,
        "exit_code": p.returncode,
        "wall_ms": round(wall_ms, 3),
        "peak_rss_bytes": peak_rss,
        "peak_rss_mb": round(peak_rss / (1024 * 1024), 3),
        "samples": samples,
        "stdout": stdout,
        "stderr": stderr,
    }

    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
