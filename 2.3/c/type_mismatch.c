#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int main(void) {
    char *s = "42";
    return add(s, 1);
}