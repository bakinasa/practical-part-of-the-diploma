# Section 2.2 — Execution model and architectural correspondence

**Goal:** Show that language differences persist at runtime; same algorithm lives differently in memory and runtime; type/paradigm affect allocations; runtime is part of the language's technical existence.

**Layer A (required):** Dijkstra — time, peak RSS, internal allocations, role of runtime.  
**Layer B (supporting):** relax_loop microbenchmark — isolates execution-model overhead.

**Structure:**
- `common/run_monitor.py` — runs a command, outputs one JSON: wall_ms, peak_rss_mb, exit_code, stdout, stderr.
- `c/` — dijkstra_22.c, relax_loop_22.c
- `rust/` — dijkstra_22.rs, relax_loop_22.rs
- `haskell/` — Dijkstra22.hs, RelaxLoop22.hs
- `python/` — dijkstra_22.py, relax_loop_22.py
- `out/` — executables and JSON logs (dijkstra_*_run1..3.json, relax_loop_*_run1..3.json)

**Outputs:** `out/` (executables, JSON logs), `report/report.txt`. Run `.\run_2_2.ps1` to build all, run each variant 3 times, and generate the report.

---

## Описание эксперимента

Практическая часть подраздела строится в два слоя. Основным кейсом сохранён алгоритм Дейкстры из раздела 1.5, что позволяет удержать преемственность между формальным и технологическим анализом. Дополнительно используется микробенчмарк **relax_loop**, изолирующий повторение элементарной численной операции (та же операция релаксации `step(old, du, w)`) и позволяющий выделить собственные накладные расходы модели исполнения вне файлового ввода, построения графа и сложных структур данных. Обе программы (Дейкстра и relax_loop) запускаются на C, Rust, Haskell и Python под единым монитором **run_monitor.py**, который измеряет время выполнения, пик потребления памяти (peak RSS) и, когда возможно, языко-специфические метрики рантайма (статистика RTS Haskell, данные tracemalloc Python и т.п.); по нескольким прогонам для каждого варианта строится отчёт, где сравнивается, как один и тот же алгоритм и одна и та же численная операция «живут» во времени и памяти в разных языках и архитектурных стек-/heap-моделях.

### run_monitor.py

Скрипт запускает произвольную команду, в цикле (каждые 10 мс) опрашивает потребление памяти процесса и дочерних (через psutil), по завершении выдаёт один JSON: `wall_ms`, `peak_rss_mb`, `stdout`, `stderr`, `exit_code`. Так каждый запуск даёт сравнимый набор метрик независимо от языка.

### Отчёт

`common/build_report.py` читает все `out/*.json`, извлекает метрики и языко-специфическую статистику (C, Rust, Haskell RTS, Python tracemalloc), формирует сводные таблицы по времени и памяти для Дейкстры и для relax_loop, детальные блоки по прогонам и список отсутствующих метрик или ошибок.

---

## Сборка и запуск

**Зависимости:** `python -m pip install psutil` (для run_monitor.py).

**Сборка (из корня репозитория или из папки 2.2):**
```text
gcc -O2 2.2/c/dijkstra_22.c -o 2.2/out/dijkstra_c_22.exe
gcc -O2 2.2/c/relax_loop_22.c -o 2.2/out/relax_loop_c_22.exe
rustc 2.2/rust/dijkstra_22.rs -C opt-level=3 -o 2.2/out/dijkstra_rust_22.exe
rustc 2.2/rust/relax_loop_22.rs -C opt-level=3 -o 2.2/out/relax_loop_rust_22.exe
ghc -O2 -rtsopts 2.2/haskell/Dijkstra22.hs -o 2.2/out/dijkstra_hs_22.exe
ghc -O2 -rtsopts 2.2/haskell/RelaxLoop22.hs -o 2.2/out/relax_loop_hs_22.exe
```

**Граф:** используется тот же `graph.txt`, что и в 1.5 (скопировать из `../1.5/` или сгенерировать скриптом 1.5). Положить в `2.2/graph.txt`.

**Запуск через монитор (примеры):**
```text
python 2.2/common/run_monitor.py 2.2/out/dijkstra_c_22.exe graph.txt
python 2.2/common/run_monitor.py 2.2/out/dijkstra_rust_22.exe graph.txt
python 2.2/common/run_monitor.py 2.2/out/dijkstra_hs_22.exe graph.txt +RTS -s
python 2.2/common/run_monitor.py python 2.2/python/dijkstra_22.py graph.txt
```
Для relax_loop те же команды, но без аргумента `graph.txt`.

**Автоматизация:** из папки 2.2 выполнить `.\run_2_2.ps1` — собирает все бинарники, запускает каждый вариант по 3 раза, сохраняет JSON в `out/`, затем строит отчёт. Отчёт также можно пересобрать вручную: `python common/build_report.py` (поддерживается UTF-8 BOM в JSON, например от PowerShell Out-File).
