#include <stdio.h>
#include "gs.h"


#ifdef LIB
extern void _start(void){
  main();
}
#endif

extern void print_hello(void){
  puts("hello");
  return;
}
/*
extern int main(){
  static char* s="\xcc\xc3";
  //((void (*)(void))s)();
  return 0;
}
*/

void brake(void){
  const char* b="\xcc\xc3";
  ((void (*)(void))b)();
  return;
}


extern int main(int arc,char** argv){
  
  printf("TLS : %p\n",getTLS());
  printf("libc : %p\n",getLibc());
  printf("code : %p\n",getCode());
  printf("strings: %p\n",getStringIndex());
  printf("gotone: %p\n",getgotone());
  void * pie_base=getpieload();
  
  if(pie_base){
    printf("pie  : %p\n",getpieload());
  }
  else{
    printf("base : %p\n",gettextload());
  }
  

  brake();

  return 0;
}

