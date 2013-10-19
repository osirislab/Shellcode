#include "stdio.h"
#include "stdlib.h"
#include "dlfcn.h"

int main() {
    void* hnd = dlopen("./input.so", RTLD_LAZY);
    if(hnd == NULL) {
        printf("%s\n", dlerror());
        exit(1);
    }

    void (*func)() = dlsym(hnd, "CALL");
    if(func == NULL) {
        printf("%s\n", dlerror());
        exit(1);
    }

    func();

    printf("HITHERE\n");
}