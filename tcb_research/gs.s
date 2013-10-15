	;; Evan Jensen
	;; 101413

	;; usefull for enumerating runtime datastructures
	;; use in conjuction with the enumeration vdb script
	BITS 32
	extern printf
	global main


	
main:

	mov eax,DWORD [gs:0]
	int3