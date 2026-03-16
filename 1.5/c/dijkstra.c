/*
 * Dijkstra: shortest paths from source. Reads graph from file.
 * Format: first line "n m source", then m lines "u v weight".
 * Runs RUNS times and prints avg_time_ms and checksum (sum of finite distances).
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <time.h>
#endif

#define MAX_N 100005
#define MAX_M 500005
#define RUNS 50

/* Ребро графа: вершина назначения и вес */
typedef struct { int to; double w; } edge_t;
static int n, m, source;
static edge_t edges[MAX_M];
static int out_start[MAX_N + 1], out_deg[MAX_N];
static double dist[MAX_N];

/* Читает граф из файла и строит компактное представление списка смежности. */
static int parse_graph(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return -1;
    if (fscanf(f, "%d %d %d", &n, &m, &source) != 3) { fclose(f); return -1; }
    /* out_count[u] — сколько исходящих рёбер у вершины u */
    int *out_count = calloc(n, sizeof(int));
    if (!out_count) { fclose(f); return -1; }
    /* Первый проход по файлу — только считаем степени вершин,
       чтобы потом знать, где в массиве edges будет начинаться список
       рёбер для каждой вершины. */
    for (int i = 0; i < m; i++) {
        int u, v;
        double w;
        if (fscanf(f, "%d %d %lf", &u, &v, &w) != 3) { free(out_count); fclose(f); return -1; }
        out_count[u]++;
    }
    /* out_start[u] — индекс первого ребра из вершины u в массиве edges.
       Дальше идёт префиксная сумма по количеству рёбер. */
    out_start[0] = 0;
    for (int i = 1; i < n; i++) out_start[i] = out_start[i-1] + out_count[i-1];
    out_start[n] = m;
    /* Перематываем файл и второй раз читаем все рёбра — теперь уже
       раскладываем их по массиву edges в нужные позиции. */
    rewind(f);
    int nn, mm, ss;
    fscanf(f, "%d %d %d", &nn, &mm, &ss);
    int *idx = calloc(n, sizeof(int));
    if (!idx) { free(out_count); fclose(f); return -1; }
    /* idx[u] показывает, сколько рёбер вершины u мы уже записали. */
    for (int i = 0; i < m; i++) {
        int u, v;
        double w;
        fscanf(f, "%d %d %lf", &u, &v, &w);
        int p = out_start[u] + idx[u]++;
        edges[p].to = v;
        edges[p].w = w;
    }
    free(out_count);
    free(idx);
    fclose(f);
    /* out_deg[u] — количество исходящих рёбер из вершины u. */
    for (int i = 0; i < n; i++) out_deg[i] = out_start[i+1] - out_start[i];
    return 0;
}

#define HEAP_MAX MAX_N
/* Бинарная куча (минимальная по расстоянию) для вершин. */
static int heap[HEAP_MAX];        /* индексы вершин */
static int heap_pos[MAX_N];       /* heap_pos[v] — позиция вершины v в куче, либо -1 */
static int heap_len;
static double heap_dist[MAX_N];   /* расстояние до вершины, по которому упорядочиваем кучу */

/* Меняет местами две вершины в куче и обновляет их позиции. */
static void heap_swap(int i, int j) {
    int a = heap[i], b = heap[j];
    heap[i] = b; heap[j] = a;
    heap_pos[a] = j; heap_pos[b] = i;
}

/* Просеивание вверх: восстанавливаем свойство кучи после уменьшения ключа. */
static void heap_up(int i) {
    while (i > 0) {
        int p = (i - 1) / 2;
        if (heap_dist[heap[i]] >= heap_dist[heap[p]]) break;
        heap_swap(i, p);
        i = p;
    }
}

/* Просеивание вниз: восстанавливаем свойство кучи после извлечения минимума. */
static void heap_down(int i) {
    for (;;) {
        int l = 2*i+1, r = 2*i+2, small = i;
        if (l < heap_len && heap_dist[heap[l]] < heap_dist[heap[small]]) small = l;
        if (r < heap_len && heap_dist[heap[r]] < heap_dist[heap[small]]) small = r;
        if (small == i) break;
        heap_swap(i, small);
        i = small;
    }
}

/* Кладём вершину v с расстоянием d в кучу. */
static void heap_push(int v, double d) {
    heap_dist[v] = d;
    heap_pos[v] = heap_len;
    heap[heap_len++] = v;
    heap_up(heap_len - 1);
}

/* Достаём вершину с минимальным расстоянием. */
static int heap_pop(void) {
    int v = heap[0];
    heap_swap(0, --heap_len);
    heap_down(0);
    return v;
}

/* Обновляем расстояние до вершины v в куче (операция decrease‑key). */
static void heap_update(int v, double d) {
    double old = heap_dist[v];
    heap_dist[v] = d;
    if (d < old) heap_up(heap_pos[v]);
}

/* Проверяем, находится ли вершина v сейчас в куче. */
static int heap_contains(int v) {
    return heap_pos[v] >= 0 && heap_pos[v] < heap_len && heap[heap_pos[v]] == v;
}

/* Returns checksum: sum of finite distances (scaled to avoid float non-associativity issues). */
/* Алгоритм Дейкстры из вершины source.
   Возвращает сумму всех достижимых расстояний (checksum). */
static double dijkstra(void) {
    /* Инициализация: -1 означает "расстояние ещё не известно" (бесконечность). */
    for (int i = 0; i < n; i++) dist[i] = -1.0;
    dist[source] = 0.0;      /* до источника расстояние 0 */
    heap_len = 0;            /* куча пока пустая */
    for (int i = 0; i < n; i++) heap_pos[i] = -1;
    /* В кучу кладём только источник. */
    heap_push(source, 0.0);
    /* Основной цикл: каждый раз берём вершину с минимальным расстоянием
       и пытаемся улучшить расстояния до её соседей. */
    while (heap_len > 0) {
        int u = heap_pop();          /* вершина с текущим минимальным dist */
        double du = dist[u];
        int start = out_start[u], end = out_start[u+1];
        /* Перебираем все рёбра u -> v. */
        for (int e = start; e < end; e++) {
            int v = edges[e].to;
            double w = edges[e].w;
            double dv = dist[v];
            double alt = du + w;     /* кандидат на улучшение расстояния до v */
            if (dv < 0 || alt < dv) {
                dist[v] = alt;
                /* Если v уже в куче — обновляем ключ, иначе добавляем. */
                if (heap_contains(v)) heap_update(v, alt);
                else heap_push(v, alt);
            }
        }
    }
    /* Считаем сумму всех конечных расстояний — это используется как checksum
       для проверки корректности работы алгоритма. */
    double sum = 0.0;
    for (int i = 0; i < n; i++)
        if (dist[i] >= 0.0) sum += dist[i];
    return sum;
}

int main(int argc, char **argv) {
    const char *path = argc > 1 ? argv[1] : "graph.txt";
    if (parse_graph(path) != 0) {
        fprintf(stderr, "Failed to read graph from %s\n", path);
        return 1;
    }
#ifdef _WIN32
    LARGE_INTEGER freq, t0, t1;
    QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&t0);
    double total_checksum = 0.0;
    for (int r = 0; r < RUNS; r++) total_checksum += dijkstra();
    QueryPerformanceCounter(&t1);
    double sec = (double)(t1.QuadPart - t0.QuadPart) / (double)freq.QuadPart;
#else
    clock_t t0 = clock();
    double total_checksum = 0.0;
    for (int r = 0; r < RUNS; r++) total_checksum += dijkstra();
    clock_t t1 = clock();
    double sec = (double)(t1 - t0) / CLOCKS_PER_SEC;
#endif
    double avg_ms = (sec * 1000.0) / RUNS;
    printf("avg_time_ms: %.2f\n", avg_ms);
    printf("checksum: %.6f\n", total_checksum);
    printf("runs: %d\n", RUNS);
    return 0;
}
