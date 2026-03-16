SHELL := /bin/bash

LOGDIR := logs

CC := gcc
CFLAGS_STRICT := -std=c17 -Wall -Wextra -Wpedantic -Werror
CFLAGS_SAN := -std=c17 -O1 -g -Wall -Wextra -Wpedantic \
	-fsanitize=address,undefined
CFLAGS_ASAN := -std=c17 -O1 -g -Wall -Wextra -Wpedantic \
	-fsanitize=address
CFLAGS_NOSAN := -std=c17 -O1 -g -Wall -Wextra -Wpedantic

RUSTC := rustc
GHC := ghc
PYTHON := python3
MYPY := mypy

.PHONY: all clean dirs c rust haskell python run

all: dirs
	@echo "Use 'make run' or './run.sh'"

dirs:
	mkdir -p $(LOGDIR)

clean:
	rm -f c/null_deref c/null_deref_nosan
	rm -f c/use_after_free
	rm -f rust/type_mismatch
	rm -f rust/option_mismatch
	rm -f rust/use_after_move
	rm -f rust/two_mut_borrows
	rm -f rust/non_exhaustive_match
	rm -f haskell/type_mismatch
	rm -f haskell/maybe_mismatch
	rm -f haskell/non_exhaustive
	rm -f haskell/*.hi haskell/*.o
	rm -rf $(LOGDIR)

run: dirs
	bash run.sh

c: dirs
	-$(CC) $(CFLAGS_STRICT) c/type_mismatch.c \
		-o c/type_mismatch 2> $(LOGDIR)/c_type_mismatch.log
	-$(CC) $(CFLAGS_SAN) c/null_deref.c \
		-o c/null_deref 2> $(LOGDIR)/c_null_deref_build.log
	-$(CC) $(CFLAGS_NOSAN) c/null_deref.c \
		-o c/null_deref_nosan 2> $(LOGDIR)/c_null_deref_nosan_build.log
	-$(CC) $(CFLAGS_ASAN) c/use_after_free.c \
		-o c/use_after_free 2> $(LOGDIR)/c_use_after_free_build.log
	-$(CC) $(CFLAGS_STRICT) -Wswitch-enum c/non_exhaustive_switch.c \
		-o c/non_exhaustive_switch \
		2> $(LOGDIR)/c_non_exhaustive_switch.log

rust: dirs
	-$(RUSTC) rust/type_mismatch.rs \
		-o rust/type_mismatch 2> $(LOGDIR)/rust_type_mismatch.log
	-$(RUSTC) rust/option_mismatch.rs \
		-o rust/option_mismatch 2> $(LOGDIR)/rust_option_mismatch.log
	-$(RUSTC) rust/use_after_move.rs \
		-o rust/use_after_move 2> $(LOGDIR)/rust_use_after_move.log
	-$(RUSTC) rust/two_mut_borrows.rs \
		-o rust/two_mut_borrows \
		2> $(LOGDIR)/rust_two_mut_borrows.log
	-$(RUSTC) rust/non_exhaustive_match.rs \
		-o rust/non_exhaustive_match \
		2> $(LOGDIR)/rust_non_exhaustive_match.log

haskell: dirs
	-$(GHC) -Wall -Werror haskell/TypeMismatch.hs \
		-o haskell/type_mismatch \
		2> $(LOGDIR)/hs_type_mismatch.log
	-$(GHC) -Wall -Werror haskell/MaybeMismatch.hs \
		-o haskell/maybe_mismatch \
		2> $(LOGDIR)/hs_maybe_mismatch.log
	-$(GHC) -Wall -Werror -Wincomplete-patterns \
		haskell/NonExhaustive.hs \
		-o haskell/non_exhaustive \
		2> $(LOGDIR)/hs_non_exhaustive.log

python: dirs
	-$(PYTHON) python/type_mismatch.py \
		> $(LOGDIR)/py_type_mismatch.out \
		2> $(LOGDIR)/py_type_mismatch.log
	-$(PYTHON) python/none_mismatch.py \
		> $(LOGDIR)/py_none_mismatch.out \
		2> $(LOGDIR)/py_none_mismatch.log
	-$(PYTHON) python/non_exhaustive.py \
		> $(LOGDIR)/py_non_exhaustive.out \
		2> $(LOGDIR)/py_non_exhaustive.log

	-$(MYPY) --strict python/type_mismatch.py \
		> $(LOGDIR)/mypy_type_mismatch.out \
		2> $(LOGDIR)/mypy_type_mismatch.log
	-$(MYPY) --strict python/none_mismatch.py \
		> $(LOGDIR)/mypy_none_mismatch.out \
		2> $(LOGDIR)/mypy_none_mismatch.log
	-$(MYPY) --strict python/non_exhaustive.py \
		> $(LOGDIR)/mypy_non_exhaustive.out \
		2> $(LOGDIR)/mypy_non_exhaustive.log
