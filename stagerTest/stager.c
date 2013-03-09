/*
Evan Jensen 030613
Code to mimic the stage loader for testing
Give it a shared library with the first 4 bytes being an offset to the entrypoint
*/

#include <unistd.h>
#include <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <inttypes.h>

#define STAGEADDR 0x10000000
#define STAGELEN  0x100000
#define RWE PROT_READ|PROT_WRITE|PROT_EXEC
#define STAGEFLAG MAP_PRIVATE | MAP_ANONYMOUS

int main(int argc,char** argv){
  if(argc<2){
    perror("Need to give a stage name");
    exit(1);
  }
  char* stageName=argv[1];
  void* stage;
  int fd=open(stageName, O_RDONLY);

  stage = mmap(STAGEADDR, STAGELEN, RWE, STAGEFLAG, NULL, NULL);
 
  read(fd,stage,STAGELEN);
  uint32_t offset = *(uint32_t*)stage;

  void (*fptr)(void)=stage;
  fptr+=offset;
  
  printf("jmping to offset %x\n", offset);
  fptr();
  return 0;
}
