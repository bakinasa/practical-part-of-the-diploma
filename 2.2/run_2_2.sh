#!/usr/bin/env bash
set -euo pipefail

# Section 2.2: build, run via run_monitor.py, save JSON (2-3 runs per variant) — Unix shell version

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ROOT="$SCRIPT_DIR"
S15="$ROOT/../1.5"
OUT="$ROOT/out"
COMMON="$ROOT/common"

mkdir -p "$OUT"

if command -v python >/dev/null 2>&1; then PY=python; else PY=python3; fi
RUNS=3

# graph.txt (same as 1.5)
GRAPH_PATH="$ROOT/graph.txt"
if [ ! -f "$GRAPH_PATH" ]; then
  S15_GRAPH="$S15/graph.txt"
  if [ -f "$S15_GRAPH" ]; then
    cp "$S15_GRAPH" "$GRAPH_PATH"
    echo "Copied graph.txt from 1.5"
  else
    pushd "$S15" >/dev/null
    "$PY" generate_graph.py "$GRAPH_PATH" 2>/dev/null || true
    popd >/dev/null
    if [ -f "$GRAPH_PATH" ]; then
      echo "Generated graph.txt via 1.5"
    else
      echo "WARNING: Create graph.txt (e.g. run 1.5 generate_graph.py)" >&2
    fi
  fi
fi

echo "Building C..."
gcc -O2 "$ROOT/c/dijkstra_22.c" -o "$OUT/dijkstra_c_22" 2>/dev/null || true
gcc -O2 "$ROOT/c/relax_loop_22.c" -o "$OUT/relax_loop_c_22" 2>/dev/null || true

echo "Building Rust..."
rustc "$ROOT/rust/dijkstra_22.rs" -C opt-level=3 -o "$OUT/dijkstra_rust_22" 2>/dev/null || true
rustc "$ROOT/rust/relax_loop_22.rs" -C opt-level=3 -o "$OUT/relax_loop_rust_22" 2>/dev/null || true

echo "Building Haskell..."
ghc -O2 -rtsopts "$ROOT/haskell/Dijkstra22.hs" -o "$OUT/dijkstra_hs_22" 2>/dev/null || true
ghc -O2 -rtsopts "$ROOT/haskell/RelaxLoop22.hs" -o "$OUT/relax_loop_hs_22" 2>/dev/null || true

MONITOR="$COMMON/run_monitor.py"

echo "Running Dijkstra variants..."
declare -a DIJKSTRA_CMDS
DIJKSTRA_CMDS+=("dijkstra_c_22:$OUT/dijkstra_c_22:$GRAPH_PATH")
DIJKSTRA_CMDS+=("dijkstra_rust_22:$OUT/dijkstra_rust_22:$GRAPH_PATH")
DIJKSTRA_CMDS+=("dijkstra_hs_22:$OUT/dijkstra_hs_22:$GRAPH_PATH:+RTS:-s")
DIJKSTRA_CMDS+=("dijkstra_python_22:$PY:$ROOT/python/dijkstra_22.py:$GRAPH_PATH")

for entry in "${DIJKSTRA_CMDS[@]}"; do
  IFS=: read -r name exe arg1 arg2 arg3 <<<"$entry"
  for ((r=1; r<=RUNS; r++)); do
    out_json="$OUT/${name}_run${r}.json"
    echo "Run $r : $name"
    "$PY" "$MONITOR" "$exe" ${arg1:+$arg1} ${arg2:+$arg2} ${arg3:+$arg3} 2>&1 | tee "$out_json" >/dev/null
  done
done

echo "Running relax_loop variants..."
declare -a RELAX_CMDS
RELAX_CMDS+=("relax_loop_c_22:$OUT/relax_loop_c_22")
RELAX_CMDS+=("relax_loop_rust_22:$OUT/relax_loop_rust_22")
RELAX_CMDS+=("relax_loop_hs_22:$OUT/relax_loop_hs_22:+RTS:-s")
RELAX_CMDS+=("relax_loop_python_22:$PY:$ROOT/python/relax_loop_22.py")

for entry in "${RELAX_CMDS[@]}"; do
  IFS=: read -r name exe arg1 arg2 <<<"$entry"
  for ((r=1; r<=RUNS; r++)); do
    out_json="$OUT/${name}_run${r}.json"
    echo "Run $r : $name"
    "$PY" "$MONITOR" "$exe" ${arg1:+$arg1} ${arg2:+$arg2} 2>&1 | tee "$out_json" >/dev/null
  done
done

echo "Building report..."
"$PY" "$COMMON/build_report.py" 2>/dev/null || true
echo "Done. JSON logs in out/, report in report/report.txt"

