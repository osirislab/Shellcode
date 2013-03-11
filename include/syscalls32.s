	;; Evan Jensen 
	;; Paolo Soto
	;; Mon Mar 11 03:53:45 EDT 2013
	;; refactoring 

	%define __NR_open   BYTE 0x5
	%define __NR_write  BYTE 0x4
	%define __NR_mmap   BYTE 0x90
	%define __NR_execve BYTE 0x11
	; %define filename   fs:0x28 ; 64 bit
	%define stackcookie [gs:0x14] ; 32 bit
