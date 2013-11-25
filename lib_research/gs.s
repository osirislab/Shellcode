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
	global getgottwo
	global patchmygot
	global patchmygotpie

	
	%define EI_NIDENT 16
	;; 	extern .dynamic
	extern _DYNAMIC
	extern _GLOBAL_OFFSET_TABLE_
	
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
	add eax,0x70
	ret


getgotzero:			;pointer to _dynamic
	mov eax, _DYNAMIC
	ret

getgotone: 			;magic loader runtime struct
	;;struct link_map
	;;{
	;;  ElfW(Addr) l_addr	;/* Base address shared object is loaded at.  */
	;;  char *l_name	;/* Absolute file name object was found in.  */
	;;  ElfW(Dyn) *l_ld	;/* Dynamic section of the shared object.  */
	;;  struct link_map *l_next, *l_prev ;/* Chain of loaded objects.  */
	;;}				     
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x68]
	ret
	
getgottwo:			;pointer to _dl_reuntime_resolve
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x30]	;/lib/ld-linux.so.2
	sub eax,16		;brittle
	ret

	
getentry:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x28]
	ret

patchmygot:
	mov edi,_GLOBAL_OFFSET_TABLE_ 
	call getgotzero
	mov [edi],eax	;got[0]	
	add edi,4		
	call getgotone
	mov [edi],eax	;got[1]
	add edi,4		
	call getgottwo
	mov [edi],eax	;got[2]
	ret

patchmygotpie:
	;; when compiled with pie, after calling a get_pc.bx function
	;; ebx will be a pointer to the global_offset_table
	mov edi,ebx
	call getgotzero
	sub eax,_GLOBAL_OFFSET_TABLE_
	add eax,ebx
	mov [edi],eax	;got[0]	
	add edi,4		
	call getgotone
	mov [edi],eax	;got[1]
	add edi,4		
	call getgottwo
	mov [edi],eax	;got[2]
	ret