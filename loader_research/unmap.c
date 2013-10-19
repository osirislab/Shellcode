#define _POSIX_C_SOURCE 200112
#define _GNU_SOURCE

#include "sys/mman.h"
#include "stdio.h"
#include "unistd.h"

#define USERLAND 0xc0000000

int main() {
    int pgsz = getpagesize();
    int pgnum = USERLAND / pgsz;

    printf("Page size: %d\n", pgsz);
    printf("Page count: %d\n", pgnum);

    for(size_t i = 0; i < pgnum; ++i) {
        if(i * pgsz < 0x8047000 || i * pgsz > 0x804a000) {
            munmap((void*) (i * pgsz), pgsz);
        }
    }
    printf("End!\n");

    return 0;
}