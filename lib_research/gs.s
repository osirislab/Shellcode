	;; Evan Jensen
	;; Finds base of libc
	;; 101413

	;; offsets of data structures may be off by as much as 0x30
	;; I'm not sure what is causing the differences
	
	BITS 32

	global getLibc
	global gettextload
	global getTLS
	global getCode
	global getpieload
	global getStringIndex
	global getgotone
	global getgotzero
	
	%define EI_NIDENT 16
	
getStringIndex:
	push esi
	push edi
	call getLibc
	
	xor edx,edx
	xor edi,edi
	mov di, WORD [eax + 50 ];e_shstrndx man elf line 237
	;; find section name string table
	mov esi, DWORD [eax + 32]  	;e_shoff man elf line 192
	mov dx, WORD[eax + 46];e_shentsize man elf 227
	imul edi,edx
	lea esi,[esi+edi]	;should be pointing to the string index
	add eax,esi
	pop edi
	pop esi
	ret
	
	
getTLS:
	mov eax,DWORD [gs:0]
	ret
	
getLibc:
	mov eax,DWORD [gs:4]
	mov eax,DWORD [eax+8]
	mov eax,DWORD [eax+12*4*4]
	mov eax,DWORD [eax]
	mov eax,DWORD [eax+4]
	mov eax,DWORD [eax]
	ret

getCode:
	pop eax
	jmp eax
	

	;; not currently working
gettextload:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x38]
	mov eax,[eax+0x34]
	mov eax,[eax+0x50]
	ret

getpieload:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x68]
	mov eax,[eax+0x0]
	ret

getmain:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x4c]
	ret

getenv:
	call getargc
	mov edx,eax
	call getargv
	lea eax, [edx+eax*4+4]
	ret
	
getargc:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x6c]
	ret
getargv:
	mov eax,DWORD [gs:0x80]
	add eax,eax+0x70
	ret


getgotone:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x68]
	ret

getgotzero:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x68]
	ret

getentry:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x28]
	ret
