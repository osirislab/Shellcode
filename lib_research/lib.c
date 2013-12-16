#define _GNU_SOURCE

#include <stdio.h>
#include <dlfcn.h>

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

int main2(){
  puts("main2");
  return 2;
}


extern int main(int argc,char** argv){  
  void* libc=getLibc();
  void* dlsym_addr = dlsym(RTLD_DEFAULT, "dlsym");
  int(*libc_start_main)() = get_libc_start_main();

  printf("__libc_start_main(): %p\n", libc_start_main);
  printf("TLS : %p\n",getTLS());
  printf("libc : %p\n",libc);
  printf("libc symtab: %p\n",find_symtab(libc));
  printf("dlsym: %p\n", dlsym_addr);
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
  start_main_wrapper_alt(main2);
  //libc_start_main(main2,0,0,0,0,0,getTLS()); 
  //We shouldn't return here.


  

  return 0;
}

