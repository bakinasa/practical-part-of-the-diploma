#include <stdio.h>

static inline double relax(double old, double du, double w) {
    double alt = du + w;
    return alt < old ? alt : old;
}

double step(double old, double du, double w) {
    return relax(old, du, w);
}

int main(void) {
    printf("%.2f\n", step(10.0, 3.0, 4.0));
    return 0;
}
