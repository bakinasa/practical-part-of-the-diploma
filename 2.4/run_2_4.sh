#!/usr/bin/env bash
set -euo pipefail

# Section 2.4: Concurrency and parallelism experiments (Unix shell version).
# Builds all, runs A (shared counter), B (parallel reduction), C (async), saves JSON to out/.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ROOT="$SCRIPT_DIR"
OUT="$ROOT/out"
COMMON="$ROOT/common"

mkdir -p "$OUT"

if command -v python >/dev/null 2>&1; then PY=python; else PY=python3; fi

# Run counts (mirroring PowerShell script, but with same reduced counts)
RUNS_A=5
RUNS_B=4
RUNS_C=4
WORKERS_A=(2 4 8)
ITERS_A=200000
N_B=20000000
WORKERS_B=(1 2 4 8)
TASKS_C=1000
DELAY_C=10

MONITOR="$COMMON/run_monitor.py"

echo "Building C..."
gcc -O2 -std=c17 -Wall -Wextra -o "$OUT/counter_c" "$ROOT/c/counter_c.c" 2>/dev/null || true
gcc -O2 -std=c17 -Wall -Wextra -o "$OUT/sum_c" "$ROOT/c/sum_c.c" 2>/dev/null || true

echo "Building Rust..."
rustc "$ROOT/rust/rust_rejected.rs" -o "$OUT/rust_rejected" 2>"$OUT/rust_rejected_build.txt" || true
rustc -O "$ROOT/rust/counter_rust.rs" -o "$OUT/counter_rust" 2>/dev/null || true
rustc -O "$ROOT/rust/sum_rust.rs" -o "$OUT/sum_rust" 2>/dev/null || true

echo "Building Haskell..."
ghc -O2 -threaded -rtsopts "$ROOT/haskell/counter_hs.hs" -o "$OUT/counter_hs" 2>/dev/null || true
ghc -O2 -threaded -rtsopts "$ROOT/haskell/sum_hs.hs" -o "$OUT/sum_hs" 2>/dev/null || true

echo "Experiment A: shared counter..."
COUNTER_C="$OUT/counter_c"
COUNTER_RUST="$OUT/counter_rust"
COUNTER_HS="$OUT/counter_hs"
COUNTER_PY="$ROOT/python/counter_py.py"

for w in "${WORKERS_A[@]}"; do
  for ((r=1; r<=RUNS_A; r++)); do
    for variant in race mutex atomic; do
      tag="c_${variant}_${w}_${ITERS_A}"
      "$PY" "$MONITOR" "$COUNTER_C" "$variant" "$w" "$ITERS_A" 2>&1 | tee "$OUT/exp_a_${tag}_run${r}.json" >/dev/null
    done
    for variant in mutex atomic; do
      tag="rust_${variant}_${w}_${ITERS_A}"
      "$PY" "$MONITOR" "$COUNTER_RUST" "$variant" "$w" "$ITERS_A" 2>&1 | tee "$OUT/exp_a_${tag}_run${r}.json" >/dev/null
    done
    for variant in race atomic mvar; do
      tag="hs_${variant}_${w}_${ITERS_A}"
      "$PY" "$MONITOR" "$COUNTER_HS" "$variant" "$w" "$ITERS_A" +RTS "-N$w" 2>&1 | tee "$OUT/exp_a_${tag}_run${r}.json" >/dev/null
    done
    for variant in race lock; do
      tag="py_${variant}_${w}_${ITERS_A}"
      "$PY" "$MONITOR" "$PY" "$COUNTER_PY" "$variant" "$w" "$ITERS_A" 2>&1 | tee "$OUT/exp_a_${tag}_run${r}.json" >/dev/null
    done
  done
done

echo "Experiment B: parallel reduction..."
SUM_C="$OUT/sum_c"
SUM_RUST="$OUT/sum_rust"
SUM_HS="$OUT/sum_hs"
SUM_PY="$ROOT/python/sum_py.py"

for w in "${WORKERS_B[@]}"; do
  for ((run=1; run<=RUNS_B; run++)); do
    if [ "$w" -eq 1 ]; then
      mode_c="seq"
    else
      mode_c="threads"
    fi
    tag="c_${mode_c}_${w}_${N_B}"
    "$PY" "$MONITOR" "$SUM_C" "$mode_c" "$w" "$N_B" 2>&1 | tee "$OUT/exp_b_${tag}_run${run}.json" >/dev/null

    tag="rust_${mode_c}_${w}_${N_B}"
    "$PY" "$MONITOR" "$SUM_RUST" "$mode_c" "$w" "$N_B" 2>&1 | tee "$OUT/exp_b_${tag}_run${run}.json" >/dev/null

    if [ "$w" -eq 1 ]; then
      mode_hs="seq"
      RTS_ARGS=("+RTS" "-N1")
    else
      mode_hs="par"
      RTS_ARGS=("+RTS" "-N$w")
    fi
    tag="hs_${mode_hs}_${w}_${N_B}"
    "$PY" "$MONITOR" "$SUM_HS" "$mode_hs" "$w" "$N_B" "${RTS_ARGS[@]}" 2>&1 | tee "$OUT/exp_b_${tag}_run${run}.json" >/dev/null

    if [ "$w" -eq 1 ]; then
      tag="py_seq_1_${N_B}"
      "$PY" "$MONITOR" "$PY" "$SUM_PY" seq 1 "$N_B" 2>&1 | tee "$OUT/exp_b_${tag}_run${run}.json" >/dev/null
    else
      for mode_py in threads processes; do
        tag="py_${mode_py}_${w}_${N_B}"
        "$PY" "$MONITOR" "$PY" "$SUM_PY" "$mode_py" "$w" "$N_B" 2>&1 | tee "$OUT/exp_b_${tag}_run${run}.json" >/dev/null
      done
    fi
  done
done

echo "Experiment C: async..."
ASYNC_PY="$ROOT/python/async_py.py"
for mode in seq threads async; do
  for ((run=1; run<=RUNS_C; run++)); do
    tag="py_${mode}_${TASKS_C}_${DELAY_C}"
    "$PY" "$MONITOR" "$PY" "$ASYNC_PY" "$mode" "$TASKS_C" "$DELAY_C" 2>&1 | tee "$OUT/exp_c_${tag}_run${run}.json" >/dev/null
  done
done

echo "Building report..."
"$PY" "$COMMON/build_report.py" 2>/dev/null || true
echo "Done. Output in out/, report in report/report.txt"

