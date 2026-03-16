#!/usr/bin/env bash
set -euo pipefail

# Section 1.5: run Dijkstra implementations, collect metrics, create report (Unix shell version)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOGDIR="logs"
REPORT="$LOGDIR/report.txt"
GRAPH="graph.txt"
mkdir -p "$LOGDIR"

# Prefer python, fall back to python3
if command -v python >/dev/null 2>&1; then
  PY=python
else
  PY=python3
fi

# Ensure graph exists (100k vertices, 500k edges); regenerate if header doesn't match
NEED_GEN=0
if [ ! -f "$GRAPH" ]; then
  NEED_GEN=1
else
  FIRST_LINE="$(head -n 1 "$GRAPH" || echo "")"
  if ! echo "$FIRST_LINE" | grep -qE '^100000[[:space:]]+500000'; then
    NEED_GEN=1
  fi
fi

if [ "$NEED_GEN" -eq 1 ]; then
  echo "Generating graph (100k vertices, 500k edges)..."
  "$PY" generate_graph.py
  if [ ! -f "$GRAPH" ]; then
    echo "Failed to generate graph" >&2
    exit 1
  fi
fi
GRAPH_PATH="$(cd "$(dirname "$GRAPH")" && pwd)/$(basename "$GRAPH")"

echo "== Section 1.5 Dijkstra metrics =="
echo

# --- Build C ---
echo "Building C..."
C_EXE="c/dijkstra"
C_BUILT=0
if gcc -O2 -std=c11 -o "$C_EXE" "c/dijkstra.c" 2>"$LOGDIR/c_build.log"; then
  C_BUILT=1
  echo "  C OK"
else
  echo "  C build failed (see $LOGDIR/c_build.log)"
fi

# --- Build Rust ---
echo "Building Rust..."
RUST_EXE="rust/dijkstra"
RUST_BUILT=0
(
  cd rust
  rustc -O -o dijkstra dijkstra.rs 2>"../$LOGDIR/rust_build.log"
) || true
if [ -x "$RUST_EXE" ]; then
  RUST_BUILT=1
  echo "  Rust OK"
else
  echo "  Rust build failed (see $LOGDIR/rust_build.log)"
fi

# --- Build Haskell ---
echo "Building Haskell..."
HS_EXE="haskell/dijkstra"
HS_BUILT=0
(
  cd haskell
  ghc -O2 -o dijkstra Dijkstra.hs 2>"../$LOGDIR/hs_build.log"
) || true
if [ -x "$HS_EXE" ]; then
  HS_BUILT=1
  echo "  Haskell OK"
else
  echo "  Haskell build failed (see $LOGDIR/hs_build.log)"
fi

echo "  Python (interpreted)"
echo

# Extract avg_time_ms from program output
run_and_parse_time() {
  # args: exe_path arg...
  local exe="$1"; shift
  local out
  if ! out="$("$exe" "$@" 2>&1)"; then
    return 1
  fi
  echo "$out" | awk '/avg_time_ms:/ {print $2; found=1} END{if(!found) exit 1}'
}

RESULTS_LANG=()
RESULTS_TIME=()
MEM_RESULTS_LANG=()
MEM_RESULTS_VAL=()

add_result() {
  RESULTS_LANG+=("$1")
  RESULTS_TIME+=("$2")
}
add_mem() {
  MEM_RESULTS_LANG+=("$1")
  MEM_RESULTS_VAL+=("$2")
}

# NOTE: измерение пикового потребления памяти портируемо сделать сложно,
# поэтому в Unix-версии сохраняем только времена выполнения.

# Run C
if [ "$C_BUILT" -eq 1 ]; then
  T=$(run_and_parse_time "./$C_EXE" "$GRAPH_PATH" || echo "")
  if [ -n "$T" ]; then
    add_result "C" "$T"
    echo "C avg_time_ms: $T"
  fi
fi

# Run Rust
if [ "$RUST_BUILT" -eq 1 ]; then
  T=$(run_and_parse_time "./$RUST_EXE" "$GRAPH_PATH" || echo "")
  if [ -n "$T" ]; then
    add_result "Rust" "$T"
    echo "Rust avg_time_ms: $T"
  fi
fi

# Run Haskell
if [ "$HS_BUILT" -eq 1 ]; then
  T=$(run_and_parse_time "./$HS_EXE" "$GRAPH_PATH" || echo "")
  if [ -n "$T" ]; then
    add_result "Haskell" "$T"
    echo "Haskell avg_time_ms: $T"
  fi
fi

# Run Python
PY_SCRIPT="python/dijkstra.py"
T=$(run_and_parse_time "$PY" "$PY_SCRIPT" "$GRAPH_PATH" || echo "")
if [ -n "$T" ]; then
  add_result "Python" "$T"
  echo "Python avg_time_ms: $T"
fi

echo

# Build simple report (без измерения памяти)
{
  echo "=============================================="
  echo "  SECTION 1.5 DIJKSTRA METRICS REPORT (Unix)"
  echo "  Graph: 100,000 vertices, 500,000 edges. 50 runs per implementation."
  echo "=============================================="
  echo
  echo "| Language | Time (ms) |"
  echo "|----------|-----------|"
  for i in "${!RESULTS_LANG[@]}"; do
    lang="${RESULTS_LANG[$i]}"
    time="${RESULTS_TIME[$i]}"
    printf '| %s | %.2f |\n' "$lang" "$time"
  done
  echo
  echo "Each implementation outputs a checksum (sum of finite distances) over all runs;"
  echo "checksums should match across C, Rust, Haskell, Python for the same graph."
} >"$REPORT"

echo "Report saved: $REPORT"

