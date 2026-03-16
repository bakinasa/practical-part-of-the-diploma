# Section 2.4 — Concurrency and parallelism

**Goals:** Show how language and runtime shape parallel execution:
- Experiment A (shared counter): where races are possible, how safety is enforced (type system vs discipline), and the cost of mutex/atomic.
- Experiment B (parallel reduction): how CPU-bound work scales with threads/processes across languages.
- Experiment C (async swarm): async as a separate execution model for many waiting tasks rather than CPU speedup.

**Structure:**
- `c/` — `counter_c.c`, `sum_c.c` (Windows threads for shared state and reduction).
- `rust/` — `rust_rejected.rs` (must not compile: `Rc<RefCell<_>>` not `Send`), `counter_rust.rs`, `sum_rust.rs`.
- `haskell/` — `counter_hs.hs`, `sum_hs.hs` (threaded, `+RTS -N`).
- `python/` — `counter_py.py` (multiprocessing counter), `sum_py.py` (seq/threads/processes), `async_py.py` (seq/threads/async).
- `common/` — `run_monitor.py` (wall_ms, peak_rss_mb, stdout, stderr), `build_report.py`.
- `out/` — executables, `exp_a_*`, `exp_b_*`, `exp_c_*` JSON logs, `rust_rejected_build.txt`.
- `report/report.txt` — generated report with tables and Rust compile error for the rejected example.

---

## Описание экспериментов

Практическая часть раздела разбита на три эксперимента, соответствующие разным режимам конкурентности: разделяемое состояние (A), вычислительный параллелизм (B) и асинхронная координация ожиданий (C).

### Эксперимент A — общий счётчик (shared counter)

Несколько работников (потоков или процессов) инкрементируют один общий счётчик по фиксированному числу итераций каждый. Ожидаемый результат: \(C_{exp} = p \cdot k\) (p — работников, k — инкрементов на одного). При отсутствии синхронизации (режим race) наблюдаемое значение обычно меньше ожидаемого из‑за гонок; при mutex/atomic/lock/MVar результат корректен. Сравниваются не только наличие гонок, но и цена синхронизации (время, память). В Rust небезопасный общий доступ (например, `Rc<RefCell<_>>` между потоками) не входит в исполняемый корпус — компилятор отклоняет такой код (`rust_rejected.rs`). Реализации: C (race/CriticalSection/InterlockedIncrement64), Rust (Mutex/AtomicU64), Haskell (IORef без синхронизации / atomicModifyIORef' / MVar), Python (multiprocessing с Value: race и Lock).

**Метрики в отчёте:** язык, вариант (race/mutex/atomic/mvar/lock), workers, ok_rate (доля прогонов с правильным счётчиком), avg_time_ms, peak_rss_mb.

### Эксперимент B — параллельная редукция (parallel reduction)

Вычислительно тяжёлая задача: редукция по диапазону с функцией mix64 (один и тот же объём n). Запуск в режиме seq (один работник, время T₁) и в параллельном режиме при p = 2, 4, 8 работниках (время Tp). Вычисляются ускорение \(S_p = T_1/T_p\) и эффективность \(E_p = T_1/(p \cdot T_p)\). Контрольная сумма при том же n совпадает во всех режимах. Позволяет оценить, как язык и модель (потоки, процессы, GIL) влияют на масштабирование CPU-bound нагрузки. В основной серии n = 20M; для Python сравниваются потоки и процессы.

**Метрики в отчёте:** язык, режим (seq/threads/par/processes), workers, avg_time_ms, speedup, efficiency, peak_rss_mb.

### Эксперимент C — async swarm

Много задач (1000), каждая выполняет задержку 10 мс и возвращает значение. Нагрузка — ожидание, а не счёт. Сравниваются три способа координации в Python: последовательное выполнение (seq), пул потоков (threads), asyncio (async). Показывает, что async ориентирован на дешёвое управление множеством ожидающих задач, а не на ускорение вычислений. Контрольная сумма равна числу задач (1000).

**Метрики в отчёте:** режим (seq/threads/async), tasks, delay_ms, avg_time_ms, peak_rss_mb, контрольная сумма.

---

## Сборка и запуск

**Build (from 2.4):**
```text
gcc -O2 -std=c17 -Wall -Wextra -o out/counter_c.exe c/counter_c.c
gcc -O2 -std=c17 -Wall -Wextra -o out/sum_c.exe c/sum_c.c
rustc rust/rust_rejected.rs   (expect failure; log to out/rust_rejected_build.txt)
rustc -O rust/counter_rust.rs -o out/counter_rust.exe
rustc -O rust/sum_rust.rs -o out/sum_rust.exe
ghc -O2 -threaded -rtsopts haskell/counter_hs.hs -o out/counter_hs.exe
ghc -O2 -threaded -rtsopts haskell/sum_hs.hs -o out/sum_hs.exe
```

**Run:** From folder `2.4` run `.\run_2_4.ps1` — builds all binaries, runs:
- **A (shared counter):** C (race/mutex/atomic), Rust (mutex/atomic), Haskell (race/atomic/mvar), Python (race/lock) for several worker counts and repetitions.
- **B (parallel reduction):** C/Rust/Haskell/Python, `seq` vs `threads`/`par`/`processes`, workers ∈ {1,2,4,8}, common `n`.
- **C (async swarm):** Python `seq` / `threads` / `async` for many tasks with fixed delay.

The script saves all monitor JSON to `out/` and then calls `python common/build_report.py`.

**Report:** `python common/build_report.py` reads `out/exp_*.json`, writes `report/report.txt` with:
- Rust rejected compile error (if any) to document forbidden shared-state pattern.
- Table A: shared counter — language, variant, workers, iterations, expected/observed, `ok` rate, `avg_time_ms`, `peak_rss_mb`.
- Table B: parallel reduction — language, mode, workers, checksum, `avg_time_ms`, speedup `T1/Tp`, efficiency `T1/(p·Tp)`, `peak_rss_mb`.
- Table C: async swarm — mode (`seq`/`threads`/`async`), tasks, `delay_ms`, checksum, `avg_time_ms`, `peak_rss_mb`.

**Dependencies:** `pip install psutil` (for `run_monitor.py` and `build_report.py`).
