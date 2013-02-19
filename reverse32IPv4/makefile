all:assemble link
assemble:
	nasm -f elf r32.s -o linkme.o
link:
	gcc -m32 linkme.o -o test
