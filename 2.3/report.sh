#!/usr/bin/env bash
set -euo pipefail

# Report generator for Section 2.3 experiments (Unix shell version)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOGDIR="logs"
REPORT="$LOGDIR/report.txt"
mkdir -p "$LOGDIR"

{
  echo "=============================================="
  echo "  SECTION 2.3 EXPERIMENT REPORT (Unix)"
  echo "  Error detection in C, Rust, Haskell, Python"
  echo "=============================================="
  echo
  echo "--- SYSTEM (basic) ---"
  uname -a || echo "uname not available"
  echo
  echo "--- COMPILERS AND VERSIONS ---"
  for cmd in gcc rustc ghc python; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "$cmd : $("$cmd" --version 2>&1 | head -n 1)"
    else
      echo "$cmd : not found"
    fi
  done
  if python -m mypy --version >/dev/null 2>&1; then
    echo "mypy : $(python -m mypy --version 2>&1)"
  else
    echo "mypy : not found"
  fi
  echo

  echo "=============================================="
  echo "  EXPERIMENT LOGS (raw files with brief labels)"
  echo "=============================================="
  echo

  declare -A DESC
  DESC["c_type_mismatch.log"]="C: type mismatch - expect compile error."
  DESC["c_non_exhaustive_switch.log"]="C: incomplete switch on enum - expect warning/error."
  DESC["c_null_deref_build.log"]="C: build null_deref with sanitizers."
  DESC["c_null_deref.log"]="C: run null_deref with sanitizers."
  DESC["c_null_deref_nosan_build.log"]="C: build null_deref without sanitizers."
  DESC["c_null_deref_nosan.log"]="C: run null_deref without sanitizers (likely crash)."
  DESC["c_use_after_free_build.log"]="C: build use_after_free with ASan."
  DESC["c_use_after_free.log"]="C: run use_after_free with ASan."
  DESC["rust_type_mismatch.log"]="Rust: type mismatch."
  DESC["rust_option_mismatch.log"]="Rust: Option vs value mismatch."
  DESC["rust_use_after_move.log"]="Rust: use after move."
  DESC["rust_two_mut_borrows.log"]="Rust: two mutable borrows."
  DESC["rust_non_exhaustive_match.log"]="Rust: non-exhaustive match."
  DESC["hs_type_mismatch.log"]="Haskell: type mismatch."
  DESC["hs_maybe_mismatch.log"]="Haskell: Maybe mismatch."
  DESC["hs_non_exhaustive.log"]="Haskell: non-exhaustive patterns."
  DESC["py_type_mismatch.log"]="Python: type mismatch at runtime."
  DESC["py_none_mismatch.log"]="Python: None mismatch at runtime."
  DESC["py_non_exhaustive.log"]="Python: non-exhaustive handling at runtime."
  DESC["mypy_type_mismatch.out"]="mypy: static type mismatch."
  DESC["mypy_none_mismatch.out"]="mypy: None mismatch."
  DESC["mypy_non_exhaustive.out"]="mypy: non-exhaustive handling."

  ORDER=(
    c_type_mismatch.log c_non_exhaustive_switch.log
    c_null_deref_build.log c_null_deref.log
    c_null_deref_nosan_build.log c_null_deref_nosan.log
    c_use_after_free_build.log c_use_after_free.log
    rust_type_mismatch.log rust_option_mismatch.log rust_use_after_move.log
    rust_two_mut_borrows.log rust_non_exhaustive_match.log
    hs_type_mismatch.log hs_maybe_mismatch.log hs_non_exhaustive.log
    py_type_mismatch.log py_none_mismatch.log py_non_exhaustive.log
    mypy_type_mismatch.out mypy_none_mismatch.out mypy_non_exhaustive.out
  )

  for f in "${ORDER[@]}"; do
    path="$LOGDIR/$f"
    echo
    echo "---------- $f ----------"
    if [[ -n "${DESC[$f]:-}" ]]; then
      echo "[Comment] ${DESC[$f]}"
    fi
    if [ -f "$path" ]; then
      cat "$path"
    else
      echo "(file missing)"
    fi
    echo
  done
} >"$REPORT"

echo "Report saved: $REPORT"

