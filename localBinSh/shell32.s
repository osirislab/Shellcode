BITS 32
	global main
main:	
	xor eax,eax
	push eax
	push 0x68732f2f
	push 0x6e69622f
	mov al,11
	mov ebx,esp
	xor ecx,ecx
	mov edx,ecx
	int 0x80
	