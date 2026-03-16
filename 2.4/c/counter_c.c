#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    MODE_RACE,
    MODE_MUTEX,
    MODE_ATOMIC
} mode_t;

static long long counter_plain = 0;
static volatile LONG64 counter_atomic = 0;
static CRITICAL_SECTION cs;

typedef struct {
    uint64_t iters;
    mode_t mode;
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

DWORD WINAPI worker(LPVOID param) {
    worker_arg_t *arg = (worker_arg_t *)param;
    for (uint64_t i = 0; i < arg->iters; i++) {
        switch (arg->mode) {
            case MODE_RACE:
                counter_plain++;
                break;
            case MODE_MUTEX:
                EnterCriticalSection(&cs);
                counter_plain++;
                LeaveCriticalSection(&cs);
                break;
            case MODE_ATOMIC:
                InterlockedIncrement64(&counter_atomic);
                break;
        }
    }
    return 0;
}

static mode_t parse_mode(const char *s) {
    if (strcmp(s, "race") == 0) return MODE_RACE;
    if (strcmp(s, "mutex") == 0) return MODE_MUTEX;
    if (strcmp(s, "atomic") == 0) return MODE_ATOMIC;
    fprintf(stderr, "Unknown mode: %s\n", s);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc < 4) {
        fprintf(stderr, "Usage: %s <race|mutex|atomic> <workers> <iters>\n", argv[0]);
        return 1;
    }

    mode_t mode = parse_mode(argv[1]);
    int workers = atoi(argv[2]);
    uint64_t iters = _strtoui64(argv[3], NULL, 10);

    if (workers <= 0 || workers > 64) {
        fprintf(stderr, "workers must be in 1..64\n");
        return 1;
    }

    counter_plain = 0;
    counter_atomic = 0;
    InitializeCriticalSection(&cs);

    HANDLE threads[64];
    worker_arg_t args[64];

    double t0 = now_ms();
    for (int i = 0; i < workers; i++) {
        args[i].iters = iters;
        args[i].mode = mode;
        threads[i] = CreateThread(NULL, 0, worker, &args[i], 0, NULL);
        if (!threads[i]) {
            fprintf(stderr, "CreateThread failed\n");
            return 1;
        }
    }

    WaitForMultipleObjects((DWORD)workers, threads, TRUE, INFINITE);
    double t1 = now_ms();

    for (int i = 0; i < workers; i++) {
        CloseHandle(threads[i]);
    }
    DeleteCriticalSection(&cs);

    unsigned long long expected = (unsigned long long)workers * iters;
    unsigned long long observed =
        (mode == MODE_ATOMIC)
            ? (unsigned long long)counter_atomic
            : (unsigned long long)counter_plain;

    printf("language: C\n");
    printf("variant: %s\n", argv[1]);
    printf("workers: %d\n", workers);
    printf("iterations_per_worker: %llu\n", (unsigned long long)iters);
    printf("expected: %llu\n", expected);
    printf("observed: %llu\n", observed);
    printf("ok: %d\n", expected == observed ? 1 : 0);
    printf("time_ms: %.3f\n", t1 - t0);

    return 0;
}
