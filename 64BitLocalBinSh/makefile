all:assemble link
assemble:
	nasm -f elf64 shell64.s -o linkme.o
	nasm shell64.s -o shellcode
link:
	gcc linkme.o -o shellcodeTest
