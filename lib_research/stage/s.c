#include "../gs.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

#define BREAK() __asm__("int3");
//extern _GLOBAL_OFFSET_TABLE_


#ifdef start
void _start(void){
  main();
}
#endif

int main(int argc,char** argv){
  BREAK();
  //mprotect(0x8049ff4&(~0xfff), 0x1000, PROT_EXEC|PROT_READ|PROT_WRITE);
  patchmygotpie();
  BREAK();
  puts("all better");
  printf("honest\n");
  return 0;
}
