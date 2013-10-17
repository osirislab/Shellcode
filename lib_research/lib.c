#include <stdio.h>
#include "gs.h"

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

extern int main(){
  
  printf("TLS : %p\n",getTLS());
  printf("libc : %p\n",getLibc());
  printf("code : %p\n",getCode());
  void * pie_base=getpieload();
  if(pie_base){
    printf("pie  : %p\n",getpieload());
  }
  else{
    printf("base : %p\n",gettextload());
  }
  return 0;
}
/*
extern void _start(){
  __asm__(
	  "int3\n"
	  );
  return 0;
}
*/
