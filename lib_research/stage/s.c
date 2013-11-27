#include "../gs.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

extern _GLOBAL_OFFSET_TABLE_;

#define BREAK() __asm__("int3");
//extern _GLOBAL_OFFSET_TABLE_


#ifdef start
void _start(void){
  main();
}
#endif

int main(int argc,char** argv){
#ifdef DEBUG
  mprotect((void*)(_GLOBAL_OFFSET_TABLE_&(~0xfff)), 0x1000, PROT_EXEC|PROT_READ|PROT_WRITE);
  BREAK();
#endif
  char buf[100];
  char* message="I'M THE BOSS\n";
  //BREAK();
  
  patchmygotpie();
  fixdynamicpie();
#ifdef DEBUG
  BREAK();
#endif
  puts("something something");
  
  printf("whatever whatever\n");
  write("%s %s\n","figgure this shit out,","Sherlock");
  
#ifdef DEBUG
  BREAK();
#endif
  return 0;
}
