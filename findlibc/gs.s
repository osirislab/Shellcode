	;; Evan Jensen
	;; Finds base of libc
	;; 101413
	BITS 32
	extern printf
	global main

format:	db "0x%08x",0xa,0

printeax:
	push eax
	push eax
	push format
	call printf
	add esp,8
	pop eax
	ret
	
main:

	mov eax,DWORD [gs:4]
	call printeax
	mov eax,DWORD [eax+8]
	call printeax
	mov eax,DWORD [eax+12*4*4]
	call printeax
	mov eax,DWORD [eax]
	call printeax
	mov eax,DWORD [eax+4]
	call printeax
	mov eax,DWORD [eax]
	call printeax
	int3
	