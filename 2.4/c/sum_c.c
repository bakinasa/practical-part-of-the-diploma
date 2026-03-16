#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    uint64_t start;
    uint64_t end;
    uint64_t result;
} worker_arg_t;

static double now_ms(void) {
    static LARGE_INTEGER freq;
    static int inited = 0;
    LARGE_INTEGER t;
    if (!inited) {
        QueryPerformanceFrequency(&freq);
        inited = 1;
    }
    QueryPerformanceCounter(&t);
    return (double)t.QuadPart * 1000.0 / (double)freq.QuadPart;
}

static inline uint64_t mix64(uint64_t x) {
    x ^= x >> 33;
    x *= 0xff51afd7ed558ccdULL;
    x ^= x >> 33;
    x *= 0xc4ceb9fe1a85ec53ULL;
    x ^= x >> 33;
    return x;
}

static uint64_t chunk_sum(uint64_t start, uint64_t end) {
    uint64_t acc = 0;
    for (uint64_t i = start; i < end; i++) {
        acc += mix64(i);
    }
    return acc;
}

DWORD WINAPI worker(LPVOID param) {
    worker_arg_t *arg = (worker_arg_t *)param;
    arg->result = chunk_sum(arg->start, arg->end);
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 4) {
        fprintf(stderr, "Usage: %s <seq|threads> <workers> <n>\n", argv[0]);
        return 1;
    }

    const char *mode = argv[1];
    int workers = atoi(argv[2]);
    uint64_t n = _strtoui64(argv[3], NULL, 10);

    if (workers <= 0 || workers > 64) {
        fprintf(stderr, "workers must be in 1..64\n");
        return 1;
    }

    double t0 = now_ms();
    uint64_t checksum = 0;

    if (strcmp(mode, "seq") == 0) {
        checksum = chunk_sum(0, n);
    } else if (strcmp(mode, "threads") == 0) {
        HANDLE threads[64];
        worker_arg_t args[64];

        uint64_t chunk = n / (uint64_t)workers;
        uint64_t cur = 0;

        for (int i = 0; i < workers; i++) {
            uint64_t next = (i == workers - 1) ? n : cur + chunk;
            args[i].start = cur;
            args[i].end = next;
            args[i].result = 0;
            threads[i] = CreateThread(NULL, 0, worker, &args[i], 0, NULL);
            cur = next;
        }

        WaitForMultipleObjects((DWORD)workers, threads, TRUE, INFINITE);

        for (int i = 0; i < workers; i++) {
            checksum += args[i].result;
            CloseHandle(threads[i]);
        }
    } else {
        fprintf(stderr, "mode must be seq|threads\n");
        return 1;
    }

    double t1 = now_ms();

    printf("language: C\n");
    printf("mode: %s\n", mode);
    printf("workers: %d\n", workers);
    printf("n: %llu\n", (unsigned long long)n);
    printf("checksum: %llu\n", (unsigned long long)checksum);
    printf("time_ms: %.3f\n", t1 - t0);

    return 0;
}
