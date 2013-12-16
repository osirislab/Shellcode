#include "../gs.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

#define BREAK() __asm__("int3");
#define RWE PROT_EXEC|PROT_READ|PROT_WRITE
//extern _GLOBAL_OFFSET_TABLE_

#ifdef start
void _start(void){
  main();
}
#endif

int test_functions(void);

int main(int argc,char** argv){
#ifdef DEBUG
  //mprotect(((int)findgotpie())&(~0xfff), 0x1000, RWE);
  printf("gs:0 %p\n", getTLS);
  mprotect( (void*)(((int)findgot())&(~0xfff)), 0x1000, RWE);
  BREAK();
#endif
   //BREAK();
  
  do_patch_pie();
  
#ifdef DEBUG
  BREAK();
#endif
  //start testing here
  
  //int(*libc_start_main)() = get_libc_start_main();
  //libc_start_main(test_functions,0,0,0,0,0,getTLS()); 
  //start_main_wrapper_alt(test_functions);
  test_functions();
  //end testing here
#ifdef DEBUG
  BREAK();
#endif
  return 0;
}

int test_functions(void){
  char buf[100];
  char* message="I'M THE BOSS\n";
  
  //BREAK();
  puts("something something");
  printf("whatever whatever\n");
  gets(buf);
  puts(buf);
  _exit(0); // regular exit will 
  return 2;//main 2
}
