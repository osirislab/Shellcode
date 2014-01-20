#Evan Jensen
#Make template for testing shellcode

RUNTIMEDIR = ../include/runtime/
INCLUDEDIR = ../include/
INCLUDE    = -I $(INCLUDEDIR) -I $(RUNTIMEDIR)
shellcode = shell64.s
NFLAGS = elf64
CFLAGS = 

all: assemble link
assemble:
	nasm -f $(NFLAGS) $(shellcode) $(INCLUDE) -o linkme.o
	nasm $(shellcode) $(INCLUDE) -o shellcode
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

clean:
	rm -f linkme.o testShellcode shellcode

