"""
Build section 2.4 report from experiment JSON outputs in out/.
Produces report/report.txt with tables for A (shared counter), B (parallel reduction), C (async).
"""
import json
import re
import sys
from pathlib import Path


def parse_stdout_kv(stdout: str) -> dict:
    out = {}
    for line in stdout.strip().splitlines():
        line = line.strip()
        if ":" in line:
            k, v = line.split(":", 1)
            out[k.strip()] = v.strip()
    return out


def load_json(path: Path) -> dict | None:
    try:
        with open(path, "r", encoding="utf-8-sig") as f:
            return json.load(f)
    except Exception:
        return None


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    root = script_dir.parent
    out_dir = root / "out"
    report_dir = root / "report"
    report_dir.mkdir(exist_ok=True)
    report_path = report_dir / "report.txt"
    lines = []

    def w(s: str = ""):
        lines.append(s)

    w("=" * 70)
    w("Section 2.4 — Concurrency and parallelism: report")
    w("=" * 70)
    w()

    # --- Rust rejected (must not compile) ---
    rejected_log = out_dir / "rust_rejected_build.txt"
    if rejected_log.exists():
        w("Rust rejected example (must not compile: Rc<RefCell<_>> not Send)")
        w("-" * 70)
        try:
            with open(rejected_log, "r", encoding="utf-8-sig") as f:
                err = f.read().strip()
        except Exception:
            err = "(read error)"
        w(err[:1500] if len(err) > 1500 else err)
        w()

    # --- Experiment A: shared counter ---
    w("Experiment A: Shared counter")
    w("=" * 70)
    a_files = sorted(out_dir.glob("exp_a_*.json"))
    by_config = {}
    for fp in a_files:
        data = load_json(fp)
        if not data:
            continue
        kv = parse_stdout_kv(data.get("stdout", ""))
        if not kv:
            continue
        # tag like c_race_2_200000
        name = fp.stem.replace("exp_a_", "").replace("_run", " ").strip()
        parts = name.split()
        if not parts:
            continue
        tag = parts[0]  # c_race_2_200000
        key = tag
        if key not in by_config:
            by_config[key] = []
        ok = kv.get("ok", "0") == "1"
        try:
            time_ms = float(kv.get("time_ms", 0))
        except (ValueError, TypeError):
            time_ms = data.get("wall_ms", 0)
        by_config[key].append({
            "expected": kv.get("expected"),
            "observed": kv.get("observed"),
            "ok": ok,
            "time_ms": time_ms,
            "peak_rss_mb": data.get("peak_rss_mb"),
        })

    w("Table: language, variant, workers, iters, expected, observed, ok_rate, avg_time_ms, avg_peak_rss_mb")
    w("-" * 70)
    for key in sorted(by_config.keys()):
        runs = by_config[key]
        if not runs:
            continue
        n = len(runs)
        ok_count = sum(1 for r in runs if r["ok"])
        avg_time = sum(r["time_ms"] for r in runs) / n
        rss = [r["peak_rss_mb"] for r in runs if r.get("peak_rss_mb") is not None]
        avg_rss = sum(rss) / len(rss) if rss else None
        first = runs[0]
        exp, obs = first.get("expected"), first.get("observed")
        # key format: lang_variant_workers_iters
        parts = key.split("_")
        lang = parts[0] if len(parts) > 0 else ""
        variant = parts[1] if len(parts) > 1 else ""
        workers = parts[2] if len(parts) > 2 else ""
        iters = parts[3] if len(parts) > 3 else ""
        rss_s = f"{avg_rss:.2f}" if avg_rss is not None else "N/A"
        w(f"  {lang}  {variant}  {workers}  {iters}  expected={exp}  observed={obs}  ok={ok_count}/{n}  avg_time_ms={avg_time:.2f}  peak_rss_mb={rss_s}")
    w()

    # --- Experiment B: parallel reduction ---
    w("Experiment B: Parallel reduction (speedup, efficiency)")
    w("=" * 70)
    b_files = sorted(out_dir.glob("exp_b_*.json"))
    by_b_config = {}
    for fp in b_files:
        data = load_json(fp)
        if not data:
            continue
        kv = parse_stdout_kv(data.get("stdout", ""))
        if not kv:
            continue
        name = fp.stem.replace("exp_b_", "").rsplit("_run", 1)[0]
        key = name
        if key not in by_b_config:
            by_b_config[key] = []
        try:
            time_ms = float(kv.get("time_ms", 0))
        except (ValueError, TypeError):
            time_ms = data.get("wall_ms", 0)
        by_b_config[key].append({
            "checksum": kv.get("checksum"),
            "time_ms": time_ms,
            "workers": kv.get("workers", "1"),
            "mode": kv.get("mode", ""),
            "peak_rss_mb": data.get("peak_rss_mb"),
        })

    # T_1 baseline per language: seq with 1 worker
    t1_by_lang = {}
    for key in by_b_config:
        parts = key.split("_")
        lang = parts[0]
        mode = parts[1] if len(parts) > 1 else ""
        w_str = parts[2] if len(parts) > 2 else "1"
        if mode in ("seq", "par") and w_str == "1":
            runs = by_b_config[key]
            if runs:
                t1 = sum(r["time_ms"] for r in runs) / len(runs)
                t1_by_lang[lang] = t1

    w("Table: language, mode, workers, checksum, avg_time_ms, speedup (T1/Tp), efficiency, peak_rss_mb")
    w("-" * 70)
    for key in sorted(by_b_config.keys()):
        runs = by_b_config[key]
        if not runs:
            continue
        parts = key.split("_")
        lang = parts[0]
        mode = parts[1] if len(parts) > 1 else ""
        workers_s = parts[2] if len(parts) > 2 else "1"
        try:
            p = int(workers_s)
        except ValueError:
            p = 1
        n = len(runs)
        avg_time = sum(r["time_ms"] for r in runs) / n
        checksum = runs[0].get("checksum", "N/A")
        t1 = t1_by_lang.get(lang)
        if t1 and t1 > 0 and p > 0:
            speedup = t1 / avg_time
            efficiency = t1 / (p * avg_time)
            sp_s = f"{speedup:.3f}"
            eff_s = f"{efficiency:.3f}"
        else:
            sp_s = "N/A"
            eff_s = "N/A"
        rss = [r["peak_rss_mb"] for r in runs if r.get("peak_rss_mb") is not None]
        rss_s = f"{sum(rss)/len(rss):.2f}" if rss else "N/A"
        w(f"  {lang}  {mode}  {workers_s}  checksum={checksum}  avg_time_ms={avg_time:.2f}  speedup={sp_s}  efficiency={eff_s}  peak_rss_mb={rss_s}")
    w()

    # --- Experiment C: async ---
    w("Experiment C: Async (timer swarm)")
    w("=" * 70)
    c_files = sorted(out_dir.glob("exp_c_*.json"))
    by_c_config = {}
    for fp in c_files:
        data = load_json(fp)
        if not data:
            continue
        kv = parse_stdout_kv(data.get("stdout", ""))
        if not kv:
            continue
        name = fp.stem.replace("exp_c_", "").rsplit("_run", 1)[0]
        key = name
        if key not in by_c_config:
            by_c_config[key] = []
        try:
            time_ms = float(kv.get("time_ms", 0))
        except (ValueError, TypeError):
            time_ms = data.get("wall_ms", 0)
        by_c_config[key].append({
            "tasks": kv.get("tasks"),
            "delay_ms": kv.get("delay_ms"),
            "checksum": kv.get("checksum"),
            "time_ms": time_ms,
            "peak_rss_mb": data.get("peak_rss_mb"),
        })

    w("Table: mode, tasks, delay_ms, checksum, avg_time_ms, avg_peak_rss_mb")
    w("-" * 70)
    for key in sorted(by_c_config.keys()):
        runs = by_c_config[key]
        if not runs:
            continue
        n = len(runs)
        avg_time = sum(r["time_ms"] for r in runs) / n
        checksum = runs[0].get("checksum", "N/A")
        tasks = runs[0].get("tasks", "N/A")
        delay = runs[0].get("delay_ms", "N/A")
        rss = [r["peak_rss_mb"] for r in runs if r.get("peak_rss_mb") is not None]
        rss_s = f"{sum(rss)/len(rss):.2f}" if rss else "N/A"
        parts = key.split("_")
        mode = parts[1] if len(parts) > 1 else key
        w(f"  {mode}  tasks={tasks}  delay_ms={delay}  checksum={checksum}  avg_time_ms={avg_time:.2f}  peak_rss_mb={rss_s}")
    w()

    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"Report written: {report_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
