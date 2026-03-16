#!/usr/bin/env bash

set -u

LOGDIR="logs"
mkdir -p "$LOGDIR"

echo "== Section 2.3 experiment runner =="
echo

echo "== Tool versions =="
{
  echo "[gcc]"
  gcc --version | head -n 1
  echo

  echo "[rustc]"
  rustc --version
  echo

  echo "[ghc]"
  ghc --version
  echo

  echo "[python]"
  python3 --version
  echo

  echo "[mypy]"
  mypy --version
  echo
} | tee "$LOGDIR/tool_versions.txt"

echo
echo "== C: compile-time checks =="
gcc -std=c17 -Wall -Wextra -Wpedantic -Werror \
  c/type_mismatch.c -o c/type_mismatch \
  > /dev/null 2> "$LOGDIR/c_type_mismatch.log" || true

gcc -std=c17 -Wall -Wextra -Wpedantic -Werror -Wswitch-enum \
  c/non_exhaustive_switch.c -o c/non_exhaustive_switch \
  > /dev/null 2> "$LOGDIR/c_non_exhaustive_switch.log" || true

echo "C compile logs saved."

echo
echo "== C: runtime checks with sanitizers =="
gcc -std=c17 -O1 -g -Wall -Wextra -Wpedantic \
  -fsanitize=address,undefined \
  c/null_deref.c -o c/null_deref \
  > /dev/null 2> "$LOGDIR/c_null_deref_build.log" || true

gcc -std=c17 -O1 -g -Wall -Wextra -Wpedantic \
  -fsanitize=address \
  c/use_after_free.c -o c/use_after_free \
  > /dev/null 2> "$LOGDIR/c_use_after_free_build.log" || true

if [[ -x c/null_deref ]]; then
  ./c/null_deref > "$LOGDIR/c_null_deref.out" \
    2> "$LOGDIR/c_null_deref.log" || true
fi

# null_deref without sanitizers: build and run to capture Segmentation Fault
gcc -std=c17 -O1 -g -Wall -Wextra -Wpedantic \
  c/null_deref.c -o c/null_deref_nosan \
  > /dev/null 2> "$LOGDIR/c_null_deref_nosan_build.log" || true
if [[ -x c/null_deref_nosan ]]; then
  ./c/null_deref_nosan > "$LOGDIR/c_null_deref_nosan.out" \
    2> "$LOGDIR/c_null_deref_nosan.log" || true
fi

if [[ -x c/use_after_free ]]; then
  ./c/use_after_free > "$LOGDIR/c_use_after_free.out" \
    2> "$LOGDIR/c_use_after_free.log" || true
fi

echo "C runtime logs saved."

echo
echo "== Rust compile-time checks =="
rustc rust/type_mismatch.rs -o rust/type_mismatch \
  > /dev/null 2> "$LOGDIR/rust_type_mismatch.log" || true

rustc rust/option_mismatch.rs -o rust/option_mismatch \
  > /dev/null 2> "$LOGDIR/rust_option_mismatch.log" || true

rustc rust/use_after_move.rs -o rust/use_after_move \
  > /dev/null 2> "$LOGDIR/rust_use_after_move.log" || true

rustc rust/two_mut_borrows.rs -o rust/two_mut_borrows \
  > /dev/null 2> "$LOGDIR/rust_two_mut_borrows.log" || true

rustc rust/non_exhaustive_match.rs -o rust/non_exhaustive_match \
  > /dev/null 2> "$LOGDIR/rust_non_exhaustive_match.log" || true

echo "Rust logs saved."

echo
echo "== Haskell compile-time checks =="
ghc -Wall -Werror haskell/TypeMismatch.hs \
  -o haskell/type_mismatch \
  > /dev/null 2> "$LOGDIR/hs_type_mismatch.log" || true

ghc -Wall -Werror haskell/MaybeMismatch.hs \
  -o haskell/maybe_mismatch \
  > /dev/null 2> "$LOGDIR/hs_maybe_mismatch.log" || true

ghc -Wall -Werror -Wincomplete-patterns haskell/NonExhaustive.hs \
  -o haskell/non_exhaustive \
  > /dev/null 2> "$LOGDIR/hs_non_exhaustive.log" || true

echo "Haskell logs saved."

echo
echo "== Python runtime =="
python3 python/type_mismatch.py \
  > "$LOGDIR/py_type_mismatch.out" \
  2> "$LOGDIR/py_type_mismatch.log" || true

python3 python/none_mismatch.py \
  > "$LOGDIR/py_none_mismatch.out" \
  2> "$LOGDIR/py_none_mismatch.log" || true

python3 python/non_exhaustive.py \
  > "$LOGDIR/py_non_exhaustive.out" \
  2> "$LOGDIR/py_non_exhaustive.log" || true

echo "Python runtime logs saved."

echo
echo "== Python static analysis (mypy) =="
mypy --strict python/type_mismatch.py \
  > "$LOGDIR/mypy_type_mismatch.out" \
  2> "$LOGDIR/mypy_type_mismatch.log" || true

mypy --strict python/none_mismatch.py \
  > "$LOGDIR/mypy_none_mismatch.out" \
  2> "$LOGDIR/mypy_none_mismatch.log" || true

mypy --strict python/non_exhaustive.py \
  > "$LOGDIR/mypy_non_exhaustive.out" \
  2> "$LOGDIR/mypy_non_exhaustive.log" || true

echo "mypy logs saved."

echo
echo "== Summary =="
echo "Generated logs in: $LOGDIR"
echo

for f in \
  c_type_mismatch.log \
  c_non_exhaustive_switch.log \
  c_null_deref.log \
  c_null_deref_nosan_build.log \
  c_null_deref_nosan.log \
  c_use_after_free.log \
  rust_type_mismatch.log \
  rust_option_mismatch.log \
  rust_use_after_move.log \
  rust_two_mut_borrows.log \
  rust_non_exhaustive_match.log \
  hs_type_mismatch.log \
  hs_maybe_mismatch.log \
  hs_non_exhaustive.log \
  py_type_mismatch.log \
  py_none_mismatch.log \
  py_non_exhaustive.log \
  mypy_type_mismatch.out \
  mypy_none_mismatch.out \
  mypy_non_exhaustive.out
do
  if [[ -f "$LOGDIR/$f" ]]; then
    echo "----- $f -----"
    head -n 8 "$LOGDIR/$f"
    echo
  fi
done

echo "Done."