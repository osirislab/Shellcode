#Evan Jensen
#Make template for testing shellcode

RUNTIMEDIR = ../include/runtime/
INCLUDEDIR = ../include/
INCLUDE    = -I $(INCLUDEDIR) -I $(RUNTIMEDIR)
SFLAGS     = -D SYSCALL

shellcode = r64.s
NFLAGS = elf64
CFLAGS = -m64

all: assemble link
assemble:
	nasm -f $(NFLAGS) $(shellcode) $(INCLUDE) $(SFLAGS) -o linkme.o
	nasm $(shellcode) $(INCLUDE) $(SFLAGS) -o shellcode 
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

clean:
	rm -f linkme.o testShellcode shellcode

