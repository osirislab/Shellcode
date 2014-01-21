#Evan Jensen
#Make template for testing shellcode

RUNTIMEDIR = ../include/runtime/
INCLUDEDIR = ../include/
INCLUDE    = -I $(INCLUDEDIR) -I $(RUNTIMEDIR)


shellcode = shell64.s
SFLAGS     = -D SYSCALL 
NFLAGS = elf64
CFLAGS = -m64

all: assemble link
assemble: $(shellcode)
	nasm -f $(NFLAGS) $(shellcode) $(INCLUDE) $(SFLAGS) -o linkme.o
	nasm $(shellcode) $(INCLUDE) $(SFLAGS) -o shellcode
link:	
	gcc linkme.o -o testShellcode $(CFLAGS)

clean:
	rm -f linkme.o testShellcode shellcode

