BITS 32
global main
	;; http://en.wikipedia.org/wiki/Executable_and_Linkable_Format
	;; program header shows what is used at runtime
	
get_entry:
	mov eax,DWORD [ebp+0x18]	;entry point
	mov ebx,DWORD [ebp+0x1c]	;addr of prgm header
	mov ecx,DWORD [ebp+0x20]	;addr of the section header table
	mov cx, WORD [ebp+0x30]	;number of entries in section header table