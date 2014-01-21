;;; Define the SYSTEM_CALL macro
;;; YOU MUST USE A %DEFINE IF YOU USE THIS MACRO
;;; Will emit a hlt instruction if no %define is present
	
%macro SYSTEM_CALL 0
	%ifdef INT80
	int 0x80
	%elifdef SYSENTER
	sysenter
	%elifdef SYSCALL
	syscall
	%elifdef CALLGATE32
	call [gs:eiz+0x10]
	%else
	hlt			
	%endif
%endmacro

%macro SYSTEM_CALL 1
	
	%ifdef INT80
	xor eax,eax;used most frequently with 32bit shellcode
	mov al, %1
	SYSTEM_CALL
	
	%elifdef SYSENTER
	int3
	hlt
	
	%elifdef SYSCALL
	push byte %1
	pop rax			;used most frequently with 64bit shellcode
	SYSTEM_CALL
	
	%elifdef CALLGATE32	;32bit only
	xor eax,eax
	mov al, %1
	SYSTEM_CALL
	
	%else
	hlt	
	%endif
%endmacro