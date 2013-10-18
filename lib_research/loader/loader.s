BITS 32
global main
	;; http://en.wikipedia.org/wiki/Executable_and_Linkable_Format
	;; program header shows what is used at runtime
	%include "../../include/short32.s"
	%include "elf_offsets.s"

	
	%define inputFD  0
	%define READSIZE 0x10000 ;64k
	%define PT_LOAD  1
	
	
get_entry:
	mov eax, DWORD [ebp + e_entry]	;entry point (RVA)
	mov ecx, DWORD [ebp + e_phoff]	;RVA of prgm header table
	add ecx, ebx			;addr of prgm header table
	xor edx, edx			;make sure high bits of edx are 0
	mov dx , WORD  [ebp + e_phnum]	;number of entries in prgm header table
	xor ebx, ebx
	mov bx , WORD  [ebp + e_phentsize] ;size of an entry in the prgm header table
	ret

	
parse_sections:
	
	

main:
	sub esp, READSIZE 
	mov eax, read
	mov ebx, inputFD
	mov ecx, esp
	mov edx, READSIZE 
	int 0x80		;read(inputFD,stack_buf,READSIZE);
	
	mov ebp,esp		;get_entry takes the base of the module in ebp
	call get_entry
	int3
	call eax		;module's main()
	
	