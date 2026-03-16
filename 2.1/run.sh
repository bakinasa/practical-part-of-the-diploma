#!/usr/bin/env bash
set -euo pipefail

# Section 2.1: build artifacts (Dijkstra from 1.5, micro from 2.1) and generate detailed report (Unix shell version)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ROOT="$SCRIPT_DIR"
S15="$ROOT/../1.5"
OUT="$ROOT/out"
REPORT_DIR="$ROOT/report"
EXCERPTS="$REPORT_DIR/excerpts"
TABLES="$REPORT_DIR/tables"

mkdir -p "$OUT/c" "$OUT/rust/O0" "$OUT/rust/O3" "$OUT/haskell" "$OUT/python"
mkdir -p "$REPORT_DIR" "$EXCERPTS" "$TABLES"

LOG=()
log() {
  LOG+=("$1")
  echo "$1"
}

log "== Section 2.1: Compilation and intermediate forms =="
log ""

log "--- System and compiler versions ---"
for cmd in gcc rustc ghc python; do
  if command -v "$cmd" >/dev/null 2>&1; then
    v="$("$cmd" --version 2>&1 | head -n 1)"
    log "$cmd : $v"
  else
    log "$cmd : not found"
  fi
done
log ""

# --- C ---
log "--- C ---"
OC="$OUT/c"
MICRO_C="$ROOT/micro/c/relax.c"
DIJKSTRA_C="$S15/c/dijkstra.c"

log "Exec: gcc -std=c17 -O0 -S \"$MICRO_C\" -o \"$OC/relax_O0.s\""
gcc -std=c17 -O0 -S "$MICRO_C" -o "$OC/relax_O0.s" 2>/dev/null || true

pushd "$ROOT/micro/c" >/dev/null
log "Exec: gcc -std=c17 -O2 -S -fdump-tree-optimized relax.c -o \"$OC/relax_O2.s\""
gcc -std=c17 -O2 -S -fdump-tree-optimized relax.c -o "$OC/relax_O2.s" 2>/dev/null || true
OPT_DUMP=$(ls *.optimized 2>/dev/null | head -n 1 || true)
if [ -n "$OPT_DUMP" ]; then
  cp "$OPT_DUMP" "$OC/relax_O2.optimized"
fi
popd >/dev/null

log "Exec: gcc -std=c17 -O2 \"$DIJKSTRA_C\" -S -o \"$OC/dijkstra_O2.s\""
gcc -std=c17 -O2 "$DIJKSTRA_C" -S -o "$OC/dijkstra_O2.s" 2>/dev/null || true

log "Exec: gcc -std=c17 -O2 \"$DIJKSTRA_C\" -o \"$OC/dijkstra_c\""
gcc -std=c17 -O2 "$DIJKSTRA_C" -o "$OC/dijkstra_c" 2>/dev/null || true
log ""

# --- Rust ---
log "--- Rust ---"
OR="$OUT/rust"
OR_O0="$OR/O0"
OR_O3="$OR/O3"
MICRO_R="$ROOT/micro/rust/relax.rs"
DIJKSTRA_R="$S15/rust/dijkstra.rs"

log "Exec: rustc micro/rust/relax.rs -C opt-level=0 --emit=asm,llvm-ir --out-dir out/rust/O0"
rustc "$MICRO_R" -C opt-level=0 --emit=asm,llvm-ir --out-dir "$OR_O0" 2>/dev/null || true
log "Exec: rustc micro/rust/relax.rs -C opt-level=3 --emit=asm,llvm-ir --out-dir out/rust/O3"
rustc "$MICRO_R" -C opt-level=3 --emit=asm,llvm-ir --out-dir "$OR_O3" 2>/dev/null || true

log "Exec: rustc ../1.5/rust/dijkstra.rs -C opt-level=3 --emit=asm -o out/rust/dijkstra_rust"
rustc "$DIJKSTRA_R" -C opt-level=3 --emit=asm -o "$OR/dijkstra_rust" 2>/dev/null || true
if [ -f "$OR/dijkstra_rust.s" ]; then
  :
elif [ -f "$OR/dijkstra_rust.asm" ]; then
  cp "$OR/dijkstra_rust.asm" "$OR/dijkstra_rust.s"
fi

log "Exec: rustc ../1.5/rust/dijkstra.rs -C opt-level=3 -o out/rust/dijkstra_rust"
rustc "$DIJKSTRA_R" -C opt-level=3 -o "$OR/dijkstra_rust" 2>/dev/null || true
log ""

# --- Haskell ---
log "--- Haskell ---"
OH="$OUT/haskell"
MICRO_H="$ROOT/micro/haskell/Relax.hs"
DIJKSTRA_H="$S15/haskell/Dijkstra.hs"

pushd "$ROOT/micro/haskell" >/dev/null
log "Exec: ghc -O0 -ddump-simpl -ddump-to-file Relax.hs -> out/haskell"
ghc -O0 -ddump-simpl -ddump-to-file -dsuppress-all Relax.hs -fforce-recomp -o "$OH/relax_O0" 2>/dev/null || true
RELAX_O0_DUMP=$(ls *.dump-simpl 2>/dev/null | head -n 1 || true)
if [ -n "$RELAX_O0_DUMP" ]; then
  cp "$RELAX_O0_DUMP" "$OH/Relax_O0.dump-simpl"
fi
log "Exec: ghc -O2 -ddump-simpl -ddump-to-file Relax.hs -> out/haskell"
ghc -O2 -ddump-simpl -ddump-to-file -dsuppress-all Relax.hs -fforce-recomp -o "$OH/relax_O2" 2>/dev/null || true
RELAX_O2_DUMP=$(ls *.dump-simpl 2>/dev/null | head -n 1 || true)
if [ -n "$RELAX_O2_DUMP" ]; then
  cp "$RELAX_O2_DUMP" "$OH/Relax_O2.dump-simpl"
fi
popd >/dev/null

log "Exec: ghc -O2 -S ../1.5/haskell/Dijkstra.hs -o out/haskell/dijkstra_hs.s"
ghc -O2 -S "$DIJKSTRA_H" -fforce-recomp -o "$OH/dijkstra_hs.s" 2>/dev/null || true
log "Exec: ghc -O2 ../1.5/haskell/Dijkstra.hs -o out/haskell/dijkstra_hs"
ghc -O2 "$DIJKSTRA_H" -fforce-recomp -o "$OH/dijkstra_hs" 2>/dev/null || true
log ""

# --- Python ---
log "--- Python ---"
OPY="$OUT/python"
MICRO_PY="$ROOT/micro/python/relax.py"
DIJKSTRA_PY="$S15/python/dijkstra.py"
if command -v python >/dev/null 2>&1; then PY=python; else PY=python3; fi

"$PY" -m dis "$MICRO_PY" 2>&1 | tee "$OPY/relax_dis.txt" >/dev/null
"$PY" "$ROOT/dis_funcs.py" "$MICRO_PY" 2>&1 | tee "$OPY/relax_funcs_dis.txt" >/dev/null
"$PY" -m py_compile "$MICRO_PY" 2>/dev/null || true
"$PY" -m py_compile "$DIJKSTRA_PY" 2>/dev/null || true
PYC_MICRO=$(find "$ROOT/micro/python" -name "relax*.pyc" 2>/dev/null | head -n 1 || true)
PYC_DIJKSTRA=$(find "$S15/python" -name "dijkstra*.pyc" 2>/dev/null | head -n 1 || true)
[ -n "$PYC_MICRO" ] && cp "$PYC_MICRO" "$OPY/relax.pyc"
[ -n "$PYC_DIJKSTRA" ] && cp "$PYC_DIJKSTRA" "$OPY/main.pyc"
log ""

# --- Sizes ---
declare -A SIZES
ARTIFACTS=(
  "C:$OC/dijkstra_c"
  "Rust:$OR/dijkstra_rust"
  "Haskell:$OH/dijkstra_hs"
)
for entry in "${ARTIFACTS[@]}"; do
  lang="${entry%%:*}"
  path="${entry#*:}"
  if [ -f "$path" ]; then
    SIZES["$lang"]="$(stat -c%s "$path" 2>/dev/null || stat -f%z "$path" 2>/dev/null || echo "")"
  else
    SIZES["$lang"]=""
  fi
done
PYC_PATH="$OPY/main.pyc"
if [ ! -f "$PYC_PATH" ]; then
  PYC_D=$(find "$S15/python" -name "dijkstra*.pyc" 2>/dev/null | head -n 1 || true)
  [ -n "$PYC_D" ] && PYC_PATH="$PYC_D"
fi
if [ -f "$PYC_PATH" ]; then
  SIZES["Python"]="$(stat -c%s "$PYC_PATH" 2>/dev/null || stat -f%z "$PYC_PATH" 2>/dev/null || echo "")"
else
  SIZES["Python"]=""
fi

# --- Report ---
REPORT_PATH="$REPORT_DIR/report.txt"
{
  echo "=============================================="
  echo "  SECTION 2.1 REPORT (Unix)"
  echo "  Compilation and interpretation as materialization of semantics"
  echo "=============================================="
  echo

  echo "1. System and compiler versions"
  echo "---"
  for line in "${LOG[@]}"; do
    echo "$line"
  done
  echo

  echo "2. Table: Artifacts by language"
  echo "---"
  echo "| Language | Intermediate form | Low-level form | Final artifact |"
  echo "|----------|-------------------|----------------|----------------|"
  echo "| C        | GCC tree dump (optimized) | asm (.s) | exe |"
  echo "| Rust     | LLVM IR           | asm            | exe |"
  echo "| Haskell  | Core (dump-simpl) | asm            | exe |"
  echo "| Python   | bytecode dis      | bytecode (VM)  | pyc |"
  echo

  echo "3. Table: Sizes (Dijkstra final artifact)"
  echo "---"
  echo "| Language | Artifact | Size (bytes) |"
  echo "|----------|----------|--------------|"
  for lang in C Rust Haskell Python; do
    sz="${SIZES[$lang]}"
    [ -z "$sz" ] && sz="N/A"
    name=""
    case "$lang" in
      C) name="dijkstra_c" ;;
      Rust) name="dijkstra_rust" ;;
      Haskell) name="dijkstra_hs" ;;
      Python) name="main.*.pyc" ;;
    esac
    echo "| $lang | $name | $sz |"
  done
  echo
} >"$REPORT_PATH"

echo "Report written: $REPORT_PATH"

