all: assemble compile link

link:
	gcc *.o -o lib -m32 -g -masm=intel

assemble:
	nasm -f elf gs.s

compile:
	gcc -c lib.c -m32 -g -masm=intel 

clean:
	rm -f gs.o
	rm -f lib.o
	rm -f lib

shared: assemble
	gcc -c lib.c -m32 -g -masm=intel --shared -fPIC
	gcc *.o -o lib -m32 -g -masm=intel --shared -fPIC

pie: assemble
	gcc -c lib.c -m32 -g -masm=intel -fPIE -pie
	gcc *.o -o lib -m32 -g -masm=intel -fPIE -pie
