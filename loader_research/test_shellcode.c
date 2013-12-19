#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc,char** argv){
  int fd=open(argv[1],O_RDONLY);
  struct stat st_fd;
  fstat(fd,&st_fd);
  void (*shellcode)(void)=mmap(NULL,st_fd.st_size,
		      PROT_EXEC|PROT_READ|PROT_WRITE, MAP_PRIVATE,fd,0);
  
  shellcode();
  return 0;
}
