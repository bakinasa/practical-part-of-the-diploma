#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    char *p = malloc(16);
    if (!p) {
        return 1;
    }

    strcpy(p, "hello");
    free(p);

    printf("%s\n", p);
    return 0;
}