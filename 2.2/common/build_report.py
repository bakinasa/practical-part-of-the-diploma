"""
Build section 2.2 report from run_monitor.py JSON outputs.
Reads all *_run*.json from out/, extracts metrics, writes report/report.txt.
Redacts project paths. Reports errors and missing metrics.
"""
import json
import os
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


def parse_haskell_rts(stderr: str) -> dict:
    rts = {}
    if not stderr:
        return rts
    # bytes allocated in the heap
    m = re.search(r"(\d[\d,\s]*)\s+bytes allocated in the heap", stderr)
    if m:
        rts["heap_bytes_allocated"] = m.group(1).replace(",", "").replace(" ", "").strip()
    # maximum residency
    m = re.search(r"(\d[\d,\s]*)\s+bytes maximum residency", stderr)
    if m:
        rts["maximum_residency_bytes"] = m.group(1).replace(",", "").replace(" ", "").strip()
    # total memory in use
    m = re.search(r"(\d+)\s+MiB total memory in use", stderr)
    if m:
        rts["total_memory_mib"] = m.group(1).strip()
    # MUT time
    m = re.search(r"MUT\s+time\s+([\d.]+)s", stderr)
    if m:
        rts["mut_time_s"] = m.group(1).strip()
    # GC time
    m = re.search(r"GC\s+time\s+([\d.]+)s", stderr)
    if m:
        rts["gc_time_s"] = m.group(1).strip()
    # Productivity
    m = re.search(r"Productivity\s+([\d.]+)% of total user", stderr)
    if m:
        rts["productivity_pct"] = m.group(1).strip()
    return rts


def redact(s: str, project_root: str) -> str:
    if not project_root or not s:
        return s
    norm = project_root.replace("\\", "/").rstrip("/")
    s = s.replace(project_root, "<project>").replace(norm, "<project>")
    return s


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    root = script_dir.parent
    out_dir = root / "out"
    report_dir = root / "report"
    report_dir.mkdir(exist_ok=True)
    report_path = report_dir / "report.txt"

    project_root = str(root)
    if len(sys.argv) > 1:
        project_root = sys.argv[1]

    json_files = sorted(out_dir.glob("*.json")) if out_dir.exists() else []
    if not json_files:
        with open(report_path, "w", encoding="utf-8") as f:
            f.write("Section 2.2 Report\nNo JSON files found in out/. Run run_2_2.ps1 first.\n")
        return 0

    lines = []
    errors = []
    missing = []

    def w(s: str = ""):
        lines.append(s)

    w("=" * 60)
    w("Section 2.2 — Report (all metrics and outputs)")
    w("=" * 60)
    w()

    # Group by variant
    by_variant = {}
    for p in json_files:
        name = p.stem
        base = re.sub(r"_run\d+$", "", name)
        by_variant.setdefault(base, []).append(p)

    dijkstra_common = ["wall_ms", "peak_rss_mb", "parse_ms", "algo_avg_ms", "checksum"]
    relax_common = ["wall_ms", "peak_rss_mb", "time_ms", "checksum"]
    c_extra = ["parse_alloc_calls", "parse_free_calls", "parse_total_bytes", "parse_peak_bytes",
               "algo_alloc_calls", "algo_free_calls", "algo_total_bytes", "algo_peak_bytes"]
    rust_extra = ["parse_alloc_calls", "parse_dealloc_calls", "parse_realloc_calls",
                  "parse_total_bytes", "parse_peak_bytes",
                  "algo_alloc_calls", "algo_dealloc_calls", "algo_realloc_calls",
                  "algo_total_bytes", "algo_peak_bytes"]
    python_extra = ["parse_peak_bytes", "algo_peak_bytes"]
    haskell_rts = ["heap_bytes_allocated", "maximum_residency_bytes", "total_memory_mib",
                   "mut_time_s", "gc_time_s", "productivity_pct"]

    # First pass: load all JSON into all_data and detail_records[(base, fname)]
    all_data = []
    detail_records = {}  # (base, fname) -> (data, kv, stdout_str, stderr_str)

    for base in sorted(by_variant.keys()):
        for fp in sorted(by_variant[base], key=lambda p: p.name):
            try:
                with open(fp, "r", encoding="utf-8-sig") as f:
                    data = json.load(f)
            except Exception as e:
                errors.append((fp.name, str(e)))
                continue
            exit_code = data.get("exit_code", None)
            stdout_str = data.get("stdout", "")
            stderr_str = data.get("stderr", "")
            kv = parse_stdout_kv(stdout_str)
            kv["wall_ms"] = data.get("wall_ms")
            kv["peak_rss_mb"] = data.get("peak_rss_mb")
            if "dijkstra" in base:
                for k in dijkstra_common:
                    if k not in kv and k in data:
                        kv[k] = data[k]
                if "c_22" in base:
                    for k in c_extra:
                        if k not in kv:
                            missing.append((fp.name, k))
                elif "rust_22" in base:
                    for k in rust_extra:
                        if k not in kv:
                            missing.append((fp.name, k))
                elif "python_22" in base:
                    for k in python_extra:
                        if k not in kv:
                            missing.append((fp.name, k))
                elif "hs_22" in base:
                    rts = parse_haskell_rts(stderr_str)
                    for k in haskell_rts:
                        if k not in rts:
                            missing.append((fp.name, f"RTS:{k}"))
                    kv["_rts"] = rts
            else:
                for k in relax_common:
                    if k not in kv and k in data:
                        kv[k] = data[k]
                if "hs_22" in base:
                    kv["_rts"] = parse_haskell_rts(stderr_str)
            if exit_code != 0:
                errors.append((fp.name, f"exit_code={exit_code}"))
            all_data.append((base, fp.name, data, kv, kv.get("_rts") or {}))
            detail_records[(base, fp.name)] = (data, kv, stdout_str, stderr_str)

    # --- Summary tables at top ---
    w("Summary tables (averages over runs per variant)")
    w("=" * 60)
    w()
    w("Dijkstra")
    w("-" * 60)
    sep = "  "
    w(sep.join(["Language", "wall_ms_avg", "peak_rss_mb_avg", "parse_ms", "algo_avg_ms", "checksum", "exit"]) + sep)
    for base in sorted(by_variant.keys()):
        if "dijkstra" not in base:
            continue
        rows = [(b, fn, dat, kv, rts) for (b, fn, dat, kv, rts) in all_data if b == base]
        if not rows:
            continue
        walls = [dat.get("wall_ms") for _, _, dat, _, _ in rows]
        walls = [x for x in walls if x is not None]
        peaks = [dat.get("peak_rss_mb") for _, _, dat, _, _ in rows]
        peaks = [x for x in peaks if x is not None]
        parses = [kv.get("parse_ms") for _, _, _, kv, _ in rows]
        algos = [kv.get("algo_avg_ms") for _, _, _, kv, _ in rows]
        checks = [kv.get("checksum") for _, _, _, kv, _ in rows]
        exits = [dat.get("exit_code") for _, _, dat, _, _ in rows]
        avg_w = sum(walls) / len(walls) if walls else 0
        avg_p = sum(peaks) / len(peaks) if peaks else 0
        parse_s = parses[0] if parses else "N/A"
        algo_s = algos[0] if algos else "N/A"
        check_s = checks[0] if checks else "N/A"
        exit_ok = "0" if all(e == 0 for e in exits) else str(exits)
        lang = base.replace("dijkstra_", "").replace("_22", "")
        w(sep.join([lang, f"{avg_w:.1f}", f"{avg_p:.2f}", str(parse_s), str(algo_s), str(check_s), exit_ok]))
    w()
    w("Relax_loop")
    w("-" * 60)
    w(sep.join(["Language", "wall_ms_avg", "peak_rss_mb_avg", "time_ms", "checksum", "exit"]) + sep)
    for base in sorted(by_variant.keys()):
        if "relax" not in base:
            continue
        rows = [(b, fn, dat, kv, rts) for (b, fn, dat, kv, rts) in all_data if b == base]
        if not rows:
            continue
        walls = [dat.get("wall_ms") for _, _, dat, _, _ in rows]
        walls = [x for x in walls if x is not None]
        peaks = [dat.get("peak_rss_mb") for _, _, dat, _, _ in rows]
        peaks = [x for x in peaks if x is not None]
        times = [kv.get("time_ms") for _, _, _, kv, _ in rows]
        checks = [kv.get("checksum") for _, _, _, kv, _ in rows]
        exits = [dat.get("exit_code") for _, _, dat, _, _ in rows]
        avg_w = sum(walls) / len(walls) if walls else 0
        avg_p = sum(peaks) / len(peaks) if peaks else 0
        time_s = times[0] if times else "N/A"
        if base == "relax_loop_hs_22" and (time_s == "0.0" or time_s == "0"):
            time_s = f"{avg_w:.1f} (wall_ms; internal timer was 0)"
        check_s = checks[0] if checks else "N/A"
        exit_ok = "0" if all(e == 0 for e in exits) else str(exits)
        lang = base.replace("relax_loop_", "").replace("_22", "")
        w(sep.join([lang, f"{avg_w:.1f}", f"{avg_p:.2f}", str(time_s), str(check_s), exit_ok]))
    w()

    w("=" * 60)
    w("Detailed per-run output")
    w("=" * 60)
    for base in sorted(by_variant.keys()):
        files = sorted(by_variant[base], key=lambda p: p.name)
        w("-" * 60)
        w(f"Variant: {base}")
        w("-" * 60)
        for fp in files:
            rec = detail_records.get((base, fp.name))
            if not rec:
                continue
            data, kv, stdout_str, stderr_str = rec
            exit_code = data.get("exit_code", 0)
            if exit_code != 0:
                w(f"  Run: {fp.name}  exit_code: {exit_code}  wall_ms: {data.get('wall_ms')}  peak_rss_mb: {data.get('peak_rss_mb')}")
            w(f"  Run: {fp.name}")
            for k, v in sorted(kv.items()):
                if k.startswith("_"):
                    continue
                w(f"    {k}: {v}")
            if kv.get("_rts"):
                w("    [RTS from stderr]")
                for k, v in sorted(kv["_rts"].items()):
                    w(f"      {k}: {v}")
            if stdout_str:
                w("    [stdout excerpt]")
                for line in stdout_str.strip().splitlines()[:5]:
                    w("      " + line)
            if stderr_str and "hs_22" in base:
                w("    [stderr RTS excerpt]")
                for line in stderr_str.strip().splitlines()[:12]:
                    w("      " + redact(line, project_root))
            if exit_code != 0 and stderr_str:
                w("    [stderr full - run failed]")
                for line in stderr_str.strip().splitlines():
                    w("      " + redact(line, project_root))
            w("    exit_code: " + str(exit_code))
            w()
    w()

    w("=" * 60)
    w("Errors (exit_code != 0 or read failure)")
    w("=" * 60)
    if not errors:
        w("None.")
    else:
        for name, msg in errors:
            w(f"  {name}: {msg}")
    w()

    w("=" * 60)
    w("Missing metrics (expected but not found)")
    w("=" * 60)
    if not missing:
        w("None.")
    else:
        by_file = {}
        for name, key in missing:
            by_file.setdefault(name, []).append(key)
        for name in sorted(by_file.keys()):
            w(f"  {name}: {', '.join(by_file[name])}")
    w()

    report_text = "\n".join(lines)
    report_text = redact(report_text, project_root)
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(report_text)

    print(f"Report written: {report_path}")
    if errors:
        print(f"Errors: {len(errors)}")
    if missing:
        print(f"Missing metrics: {len(missing)} (see report)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
