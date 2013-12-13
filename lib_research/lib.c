#include <stdio.h>
#include "gs.h"


#define BREAK() __asm__("int3")

#ifdef LIB
extern void _start(void){
  main();
}
#endif

extern void print_hello(void){
  puts("hello");
  return;
}


extern int main(int arc,char** argv){  
  printf("TLS : %p\n",getTLS());
  printf("libc : %p\n",getLibc());
  printf("ld.so : %p\n",find_loader_by_place());
  printf("code : %p\n",getCode());
  printf("strings: %p\n",getStringIndex());
  printf("ELF header: %p\n",findelfheader());
  printf("gotzero: %p\n",getgotzero());
  printf("gotone: %p\n",getgotone());
  printf("gottwo: %p\n",getgottwo());
  
  void * pie_base=getpieload();
  
  if(pie_base){
    printf("pie  : %p\n",getpieload());
  }
  else{
    printf("base : %p\n",gettextload());
  }
  
  BREAK();
  

  return 0;
}

