#include <unistd.h>
#include <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define STAGEADDR 0x10000000
#define STAGELEN  0x10000
#define RWE PROT_READ|PROT_WRITE|PROT_EXEC
#define STAGEFLAG MAP_PRIVATE

int main(int argc,char** argv){
  if(argc<2){
    perror("Need to give a stage name");
    exit(1);
  }
  char* stageName=argv[1];
  void* stage;
  int fd=open(stageName, O_RDONLY);

  stage = mmap(STAGEADDR, STAGELEN, RWE, STAGEFLAG, fd, NULL);
  
  
  //  read(fd,stage,STAGELEN);
  
  void (*fptr)(void)=stage;
  
  fptr();
  return 0;
}
