# Section 2.1 — Compilation and interpretation as materialization of semantics

**Local goal:** Empirically show that compilation and interpretation are not neutral technical stages but mechanisms that materialize the formal semantics of a language.

**Research questions:**
1. What intermediate forms appear between source and execution?
2. How do different languages reflect the same computational step at IR, assembly, or bytecode level?
3. What semantic differences are visible at translation time, before execution?

**Structure:**
- **Part A (Dijkstra):** Full case — artifact sizes, comparison of executable forms. **Sources from `../1.5`** (no duplication).
- **Part B (micro):** Relaxation step only — IR, assembly, inlining, one semantic operation across languages.

**Outputs:** `out/` (artifacts), `report/` (tables, excerpts). Run `.\run.ps1` to build all and generate the report.

---

## Описание эксперимента

### Функции relax и step

**relax** — одна элементарная операция релаксации из алгоритма Дейкстры. Во всех языках она делает одно и то же:
- вычисляет кандидат на новое расстояние: `alt = du + w` (путь через ребро с весом `w` от вершины с расстоянием `du`);
- возвращает минимум из `alt` и текущего расстояния `old`: оценка улучшается только если найден более короткий путь.

В полном Дейкстре (1.5) такая операция вызывается многократно при обходе рёбер; в 2.1 из неё сделан отдельный микромодуль, чтобы наблюдать, как одна и та же семантика представляется в IR, ассемблере или байткоде разных языков.

**step** — обёртка, которая просто вызывает `relax` с теми же аргументами. Она нужна для эксперимента:
- при **O0** в ассемблере видны две отдельные функции (`step` вызывает `relax`);
- при **O2** компилятор делает инлайнинг: тело `relax` встраивается в `step`, в ассемблере может остаться один блок для `step`.

Так показывается, что одна и та же семантика по-разному материализуется в зависимости от уровня оптимизации.

### Уровни оптимизации (O0, O2, O3)

- **O0** — без оптимизаций: быстрая компиляция, код близок к исходному, в ассемблере явно видны вызовы функций.
- **O2** — стандартный «продакшен» уровень: инлайнинг, оптимизация циклов и т.д.; в 2.1 при O2 видно, что `relax` встраивается в `step`.
- **O3** (в скрипте используется для Rust) — более агрессивные оптимизации.

Сравнение O0 и O2 (и O3 для Rust) в отчёте показывает: семантика одна (relax/step), а материализация в коде/IR/ассемблере разная.
