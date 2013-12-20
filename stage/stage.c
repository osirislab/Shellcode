#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/select.h>
#include <stdbool.h>

#include "runtime/gs.h"

#define BREAK() __asm__("int3");


int    global_argv;
char** global_argc;
char** global_envp;


#ifdef start
void _start(void){
  main();
}
#endif

int test_functions(int, char**, char**);
void do_child(char* command);
void print_arg_env(char**,char**);
void fork_and_communicate(void);
bool shell_command(char*);

bool shell_command(char* command){
  if(strcmp(command,"get_env")==0){
    //print_arg_env(global_argv, global_envp);
    return true;
  }
  if(strcmp(command,"exit")==0){
    _exit(0);
  }
  
  return false;
  
}

int main(int argc,char** argv,char** envp){

#ifdef DEBUG  
  
  test_functions(argc, argv, envp);
  _exit(0);
#endif
  do_patch_pie();
  
  
  start_main_wrapper_alt(test_functions);
  
}

int test_functions(int argc, char** argv, char** envp){
  /* global_argc = argc; */
  /* global_argv = argv; */
  /* global_envp = envp; */
  
  
  print_arg_env(argv,envp);
  //system("/bin/sh");
  while(true){
    fork_and_communicate();
  }
  
  
  _exit(0);
  return 0;//main 2
}

void do_child(char* command){
  int res=system(command);
  _exit(0);
}

void print_arg_env(char** argv,char** envp){
  _IO_puts("----------ARGS----------");
  while(*argv){
    _IO_puts(*(argv++));
  }
  _IO_puts("----------ENV----------");
  while(*envp){
    _IO_puts(*(envp++));
  }
  fflush(NULL);
  return;
}


void fork_and_communicate(void){
  
  /* int pipe_fd[2]; */
  /* __pipe(pipe_fd); */
  /* int read_fd=pipe_fd[0], write_fd=pipe_fd[1];  */
 
  /* fd_set select_r_fds; */
  /* fd_set select_w_fds; */
  /* fd_set select_x_fds; */
  /* int max_fd=0; */
  /* FD_ZERO(&select_r_fds); */
  /* FD_ZERO(&select_w_fds); */
  /* FD_ZERO(&select_x_fds); */
  
  pid_t child;

  char command[0x1000];
  memset(command,0,sizeof(command));
  gets(command);

  if((child=__fork())<0){
    puts("There was a problem forking");
    fflush(NULL);
  }
  else{
    if(child==0){
      /* dup2(read_fd,  STDIN_FILENO); */
      /* dup2(write_fd, STDOUT_FILENO); */
      //maybe do some parsing here to see if the shell will handle this
      if(!shell_command(command))
	do_child(command);
      //child exits
    }
    else{
      wait(child);
      /* __close(read_fd); */
      /* __close(write_fd); */
      
    }
  }
  return;
}
