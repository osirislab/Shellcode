CFLAGS=-m32 -g -masm=intel
SLFLAGS=-Wl,-Bstatic -static-libgcc -static

all: assemble compile link

link:
	gcc *.o -o lib $(CFLAGS)

assemble:
	nasm -f elf gs.s

compile:
	gcc -c lib.c $(CFLAGS)

clean:
	rm -f gs.o
	rm -f lib.o
	rm -f lib
	clear;clear

shared: assemble
	gcc -c lib.c $(CFLAGS) --shared -fPIC -D LIB
	gcc *.o -o lib $(CFLAGS) --shared -fPIC -D LIB

pie: assemble
	gcc -c lib.c  $(CFLAGS) -fPIE -pie
	gcc *.o -o lib  $(CFLAGS) -fPIE -pie

sharedstatic: assemble
	gcc -c lib.c $(CFLAGS) --shared -fPIC  $(SLFLAGS) -D LIB
	gcc *.o -o lib $(CFLAGS) --shared -fPIC  $(SLFLAGS) -D LIB

piestatic: assemble
	gcc -c lib.c $(CFLAGS) -fPIE -pie  $(SLFLAGS) 
	gcc *.o -o lib $(CFLAGS) -fPIE -pie  $(SLFLAGS) 
