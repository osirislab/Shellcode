	;; define the SYSTEM_CALL macro


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
	hlt			;YOU MUST USE A %DEFINE IF YOU USE THIS MACRO
	%endif
%endmacro