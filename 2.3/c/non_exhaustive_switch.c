#include <stdio.h>

typedef enum {
    RED,
    GREEN,
    BLUE
} Color;

int to_code(Color c) {
    switch (c) {
        case RED:
            return 1;
        case GREEN:
            return 2;
    }
    return 0;
}

int main(void) {
    printf("%d\n", to_code(BLUE));
    return 0;
}