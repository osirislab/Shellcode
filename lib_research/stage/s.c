#include "../gs.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>


//extern _GLOBAL_OFFSET_TABLE_

int main(int argc,char** argv){
  mprotect(0x8049ff4&(~0xfff), 0x1000, PROT_EXEC|PROT_READ|PROT_WRITE);
  patchmygot();
  puts("all better");
  printf("honest\n");
  return 0;
}
