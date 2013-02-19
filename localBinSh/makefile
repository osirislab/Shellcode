all: assemble link
assemble:
	nasm -f elf shell32.s -o linkme.o
	nasm shell32.s -o shellcode
link:
	gcc -m32 linkme.o -o testShellcode

clean:
	rm linkme.o
	rm testShellcode
	rm shellcode
