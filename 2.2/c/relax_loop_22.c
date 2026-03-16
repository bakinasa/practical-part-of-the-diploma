#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <time.h>
#endif

#define ITERS 100000000

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

static double step(double old, double du, double w) {
    double alt = du + w;
    return alt < old ? alt : old;
}

int main(void) {
    double acc = 0.0;
    double old = 1000000.0;
    double du = 1.0;
    double w = 0.5;

    double t0 = now_sec();
    for (int i = 0; i < ITERS; i++) {
        old = step(old, du, w);
        du += 0.000001;
        w += 0.000002;
        acc += old;
        if (du > 1000.0) du = 1.0;
        if (w > 1000.0) w = 0.5;
    }
    double ms = (now_sec() - t0) * 1000.0;

    printf("time_ms: %.2f\n", ms);
    printf("checksum: %.6f\n", acc);
    printf("iters: %d\n", ITERS);
    return 0;
}
