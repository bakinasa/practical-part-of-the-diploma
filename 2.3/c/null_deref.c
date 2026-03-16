#include <stdio.h>

int inc(const int *p) {
    return *p + 1;
}

int main(void) {
    int *p = NULL;
    printf("%d\n", inc(p));
    return 0;
}