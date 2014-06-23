#Evan Jensen


RUNTIMEDIR = ../include/runtime/
INCLUDEDIR = ../include/
INCLUDE    = -I $(INCLUDEDIR) -I $(RUNTIMEDIR)
shellcode  = shell32.s
NFLAGS     = -f elf -D ELF
SFLAGS     = -D INT80
CFLAGS     = -m32 


all: assemble link
assemble:
	nasm $(NFLAGS) $(shellcode) $(INCLUDE) $(SFLAGS)  -o linkme.o
	nasm $(shellcode) $(INCLUDE) $(SFLAGS) -o shellcode
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

clean:
	rm -f linkme.o testShellcode shellcode

