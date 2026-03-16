#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <time.h>
#endif

#define MAX_N 100005
#define MAX_M 500005
#define RUNS 50

typedef struct {
    unsigned long long alloc_calls;
    unsigned long long free_calls;
    size_t total_bytes;
    size_t current_bytes;
    size_t peak_bytes;
} mem_stats_t;

typedef enum {
    PHASE_NONE = 0,
    PHASE_PARSE = 1,
    PHASE_ALGO = 2
} phase_t;

static phase_t current_phase = PHASE_NONE;
static mem_stats_t parse_stats = {0};
static mem_stats_t algo_stats = {0};

static mem_stats_t *active_stats(void) {
    if (current_phase == PHASE_PARSE) return &parse_stats;
    if (current_phase == PHASE_ALGO) return &algo_stats;
    return NULL;
}

static void note_alloc(size_t bytes) {
    mem_stats_t *s = active_stats();
    if (!s) return;
    s->alloc_calls++;
    s->total_bytes += bytes;
    s->current_bytes += bytes;
    if (s->current_bytes > s->peak_bytes) {
        s->peak_bytes = s->current_bytes;
    }
}

static void note_free(size_t bytes) {
    mem_stats_t *s = active_stats();
    if (!s) return;
    s->free_calls++;
    if (s->current_bytes >= bytes) {
        s->current_bytes -= bytes;
    } else {
        s->current_bytes = 0;
    }
}

static void *xcalloc(size_t n, size_t size) {
    void *p = calloc(n, size);
    if (p) note_alloc(n * size);
    return p;
}

static void xfree(void *p, size_t bytes) {
    if (!p) return;
    note_free(bytes);
    free(p);
}

static double now_sec(void) {
#ifdef _WIN32
    static LARGE_INTEGER freq;
    static int init = 0;
    LARGE_INTEGER t;
    if (!init) {
        QueryPerformanceFrequency(&freq);
        init = 1;
    }
    QueryPerformanceCounter(&t);
    return (double)t.QuadPart / (double)freq.QuadPart;
#else
    return (double)clock() / CLOCKS_PER_SEC;
#endif
}

typedef struct {
    int to;
    double w;
} edge_t;

static int n, m, source;
static edge_t edges[MAX_M];
static int out_start[MAX_N + 1], out_deg[MAX_N];
static double dist[MAX_N];

static int parse_graph(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return -1;

    if (fscanf(f, "%d %d %d", &n, &m, &source) != 3) {
        fclose(f);
        return -1;
    }

    int *out_count = xcalloc((size_t)n, sizeof(int));
    if (!out_count) {
        fclose(f);
        return -1;
    }

    for (int i = 0; i < m; i++) {
        int u, v;
        double w;
        if (fscanf(f, "%d %d %lf", &u, &v, &w) != 3) {
            xfree(out_count, (size_t)n * sizeof(int));
            fclose(f);
            return -1;
        }
        out_count[u]++;
    }

    out_start[0] = 0;
    for (int i = 1; i < n; i++) {
        out_start[i] = out_start[i - 1] + out_count[i - 1];
    }
    out_start[n] = m;

    rewind(f);

    {
        int nn, mm, ss;
        fscanf(f, "%d %d %d", &nn, &mm, &ss);
    }

    int *idx = xcalloc((size_t)n, sizeof(int));
    if (!idx) {
        xfree(out_count, (size_t)n * sizeof(int));
        fclose(f);
        return -1;
    }

    for (int i = 0; i < m; i++) {
        int u, v;
        double w;
        fscanf(f, "%d %d %lf", &u, &v, &w);
        int p = out_start[u] + idx[u]++;
        edges[p].to = v;
        edges[p].w = w;
    }

    xfree(out_count, (size_t)n * sizeof(int));
    xfree(idx, (size_t)n * sizeof(int));
    fclose(f);

    for (int i = 0; i < n; i++) {
        out_deg[i] = out_start[i + 1] - out_start[i];
    }

    return 0;
}

#define HEAP_MAX MAX_N
static int heap[HEAP_MAX], heap_pos[MAX_N], heap_len;
static double heap_dist[MAX_N];

static void heap_swap(int i, int j) {
    int a = heap[i], b = heap[j];
    heap[i] = b;
    heap[j] = a;
    heap_pos[a] = j;
    heap_pos[b] = i;
}

static void heap_up(int i) {
    while (i > 0) {
        int p = (i - 1) / 2;
        if (heap_dist[heap[i]] >= heap_dist[heap[p]]) break;
        heap_swap(i, p);
        i = p;
    }
}

static void heap_down(int i) {
    for (;;) {
        int l = 2 * i + 1, r = 2 * i + 2, small = i;
        if (l < heap_len && heap_dist[heap[l]] < heap_dist[heap[small]]) {
            small = l;
        }
        if (r < heap_len && heap_dist[heap[r]] < heap_dist[heap[small]]) {
            small = r;
        }
        if (small == i) break;
        heap_swap(i, small);
        i = small;
    }
}

static void heap_push(int v, double d) {
    heap_dist[v] = d;
    heap_pos[v] = heap_len;
    heap[heap_len++] = v;
    heap_up(heap_len - 1);
}

static int heap_pop(void) {
    int v = heap[0];
    heap_swap(0, --heap_len);
    heap_down(0);
    return v;
}

static void heap_update(int v, double d) {
    double old = heap_dist[v];
    heap_dist[v] = d;
    if (d < old) heap_up(heap_pos[v]);
}

static int heap_contains(int v) {
    return heap_pos[v] >= 0 && heap_pos[v] < heap_len &&
        heap[heap_pos[v]] == v;
}

static double dijkstra(void) {
    for (int i = 0; i < n; i++) dist[i] = -1.0;
    dist[source] = 0.0;
    heap_len = 0;
    for (int i = 0; i < n; i++) heap_pos[i] = -1;
    heap_push(source, 0.0);

    while (heap_len > 0) {
        int u = heap_pop();
        double du = dist[u];
        int start = out_start[u], end = out_start[u + 1];
        for (int e = start; e < end; e++) {
            int v = edges[e].to;
            double w = edges[e].w;
            double dv = dist[v];
            double alt = du + w;
            if (dv < 0.0 || alt < dv) {
                dist[v] = alt;
                if (heap_contains(v)) heap_update(v, alt);
                else heap_push(v, alt);
            }
        }
    }

    double sum = 0.0;
    for (int i = 0; i < n; i++) {
        if (dist[i] >= 0.0) sum += dist[i];
    }
    return sum;
}

int main(int argc, char **argv) {
    const char *path = argc > 1 ? argv[1] : "graph.txt";

    double t0 = now_sec();
    current_phase = PHASE_PARSE;
    if (parse_graph(path) != 0) {
        fprintf(stderr, "Failed to read graph from %s\n", path);
        return 1;
    }
    current_phase = PHASE_NONE;
    double parse_ms = (now_sec() - t0) * 1000.0;

    double t1 = now_sec();
    current_phase = PHASE_ALGO;
    double total_checksum = 0.0;
    for (int r = 0; r < RUNS; r++) {
        total_checksum += dijkstra();
    }
    current_phase = PHASE_NONE;
    double algo_avg_ms = ((now_sec() - t1) * 1000.0) / RUNS;

    printf("parse_ms: %.2f\n", parse_ms);
    printf("algo_avg_ms: %.2f\n", algo_avg_ms);
    printf("checksum: %.6f\n", total_checksum);
    printf("runs: %d\n", RUNS);

    printf("parse_alloc_calls: %llu\n", (unsigned long long)parse_stats.alloc_calls);
    printf("parse_free_calls: %llu\n", (unsigned long long)parse_stats.free_calls);
    printf("parse_total_bytes: %zu\n", parse_stats.total_bytes);
    printf("parse_peak_bytes: %zu\n", parse_stats.peak_bytes);

    printf("algo_alloc_calls: %llu\n", (unsigned long long)algo_stats.alloc_calls);
    printf("algo_free_calls: %llu\n", (unsigned long long)algo_stats.free_calls);
    printf("algo_total_bytes: %zu\n", algo_stats.total_bytes);
    printf("algo_peak_bytes: %zu\n", algo_stats.peak_bytes);

    return 0;
}
