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
	global fixdynamicpie
	global findelfheader
	global findgotpie
	global findgot
	global find_loader_by_place
	global find_loader_by_name
	global find_symtab
	global get_libc_start_main
	global get_sack_begin
	global start_main_wrapper
	global get_stack
	global start_main_wrapper_alt
	global get_base_pie
	global do_patch_pie
	global patch_host_dynamic_reloc
	global patch_l_info
	
	extern _DYNAMIC
	extern _GLOBAL_OFFSET_TABLE_

	%define EI_NIDENT 16
	%define DYNAMICPTRS 0x6a230f8
	%define ELFHEADER 0x464c457f

	;; http://www.sco.com/developers/gabi/latest/ch5.dynamic.html
	;; hex(sum(map(lambda b:1<<b,[3,4,5,6,7,12,13,17,21,23,25,26])))

get_base_pie:
	mov eax,ebx
	sub eax,_GLOBAL_OFFSET_TABLE_
	ret

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

get_stack:
	mov eax,DWORD [gs:0x80]
	ret


get_libc_start_main:
	mov eax,DWORD [gs:0x80]
	mov eax,[eax+0x34]	;libc_start_main+0x9
	sub eax,9
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

get_dynamic:	
getgotzero:			;pointer to _dynamic
	mov eax, _DYNAMIC
	ret

get_dynamic_pie:
	mov eax, _DYNAMIC
	add eax, ebx
	sub eax, _GLOBAL_OFFSET_TABLE_
	ret

get_link_map:	
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
	
patch_link_map:
	call get_link_map
	mov ecx,eax
	call get_dynamic_pie
	mov [ecx+8], eax	;link_map[0].l_ld = my_dynamic_section
	call get_base_pie
	mov [ecx], eax		;link_map[0].l_addr= my_base_load
	
	;; link_map[0].l_addr is used as an offset into the GOT
	;; 0xb7fec2df <_dl_fixup+271>:	mov    DWORD PTR [edx+ebp*1],eax
	;; edx == orig_got ebp=l_ld eax=function_addr from lookup
	ret

	
	
get_runtime_resolve:	
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

fixdynamicpie:
	push ebp
	push esi
	call getgotzero		;.dynamic
	sub eax,_GLOBAL_OFFSET_TABLE_
	add eax,ebx
	mov esi, eax		;esi is what will walk the dynamic section

	mov ebp,ebx
	sub ebp,_GLOBAL_OFFSET_TABLE_ ;ebp is our base load addr
	cld
 .test:
	lodsd
	test eax,eax
	jz fixdynamicpie.fin
	mov ecx,eax
	lodsd
	cmp ecx,0x1f
	ja fixdynamicpie.test	;if value of d_un>31 look at the next one
	;; what follows is one of my favorite compiler tricks
	mov edx,1
	shl edx,cl
	and edx,DYNAMICPTRS
	;;https://isisblogs.poly.edu/2013/05/06/oh-compiler-you-so-crazy/
	jz .test
	add eax, ebp
	;; eax holds the corrected ptr value
	mov [esi-4], eax
	jmp .test
 .fin:
	pop esi
	pop ebp
	ret

findelfheader:
	call getCode
 .test:
	mov ecx,[eax]
	cmp ecx,ELFHEADER
	jz findelfheader.fin
	dec eax
	jmp findelfheader.test
 .fin:
	ret

findgotpie:
	call findelfheader
	add eax, _GLOBAL_OFFSET_TABLE_
	ret

findgot:
	mov eax, _GLOBAL_OFFSET_TABLE_
	ret
	
	;; http://linuxgazette.net/85/sandeep.html
	;; /usr/include/link.h
	;; loader should be the last element of this list
	
	%define link_map_flink 4*3
find_loader_by_place:
	call get_link_map
.begin:
	cmp [eax+link_map_flink],dword 0
	jz  find_loader_by_place.done
	mov eax, [eax + link_map_flink]
	jmp find_loader_by_place.begin
.done:	
	mov eax, [eax]		;link_map.l_addr
	ret


	
%define SHT_SYMTAB 2
%define SHT_SIZE 40
find_symtab:
	mov eax,[esp+4]		;base load of module
	mov edx,[eax+32]	;e_shoff
	add edx,eax		;addr shection headers
	movzx ecx,word [eax+48]	;number of section headers
.begin:
	cmp [edx+4], dword SHT_SYMTAB ; are we there yet?
	jz  find_symtab.done
	add edx, SHT_SIZE
	loop find_symtab.begin
	;; error out
	xor eax,eax
	ret
	
.done:
	mov eax,[edx+12]	;Elf32_Addr sh_addr
	;; 	add eax,edx		
	ret

start_main_wrapper:
	call get_stack
	mov ecx,[esp+4]
	push eax
	push 0
	push 0
	push 0
	push 0
	push 0
	push ecx
	call get_libc_start_main
	call eax
	;; no return from libc_start_main
	
start_main_wrapper_alt:
	;; call libc_start_main
	;; with most of the original arguments
	;; this function doesn't return we can ignore calling conventions
	mov edi,[esp+4]		;void(*)(void)
	mov ecx,[gs:0x80]
	lea esp,[ecx+0x4c]
	mov [esp], edi 		;rewrite the pointer to main
	mov eax,[esp-4]		;return addr
	sub eax,5		;adjust for the width of the call instruction
	jmp eax			
	;; no return from libc_start_main

do_patch_pie:
	call patchmygotpie
	call fixdynamicpie
	;; 	call patch_host_dynamic_reloc
 	call patch_link_map ; does this even do anything?
	call patch_l_info
	ret

	
	%define RELOC 0x17
	;; this function is bad.
	;; the reloc section of the host is not writable
patch_host_dynamic_reloc:
	call get_link_map	; get host got
	mov eax,[eax+8]		; eax has the got	
.cnt:
	cmp [eax],dword RELOC		;is this the item to patch?
	jz patch_host_dynamic_reloc.patch ;if yes, patch
	cmp [eax],dword 0	;hit the end of the dynamic section?
	jnz patch_host_dynamic_reloc.not_done
	xor eax,eax		;we hit the end without finding our item
	ret			;error out
.not_done:
	add eax,8		;continue to next elem in _dynamic
	jmp patch_host_dynamic_reloc.cnt		
	; we have found the item to patch. Time to patch it.
.patch:
	mov ecx,eax
	call get_dynamic_pie
	mov [ecx+4], eax 	;patch it!
	ret

	
	;; the structure we're looking to patch
	;; is located directly behind the first element
	;; of the link_map linked list
	;; the index of pointers in this list coresponds
	;; to the magic value inside the .dynamic section
patch_l_info:
	call get_link_map
	add eax,0x20
	mov edx,eax
	call get_dynamic_pie
.begin:
	mov ecx,[eax]		;grab element from dynamic
	test ecx, ecx
	jz patch_l_info.done
	;;
	cmp ecx,32
	;;
	jb  patch_l_info.patch
	;; 	cmp ecx,RELOC
	;; 	jz patch_l_info.patch
	add eax,8		;walk dynamic
	jmp patch_l_info.begin
.patch:
	shl ecx,2
	mov [edx+ecx], eax	;index l_info with ecx
	add eax,8
	jmp patch_l_info.begin
.done:
	ret
	

	