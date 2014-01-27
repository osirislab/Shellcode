#Evan Jensen
#Make template for testing shellcode

RUNTIMEDIR = ../include/runtime/
INCLUDEDIR = ../include/
INCLUDE    = -I $(INCLUDEDIR) -I $(RUNTIMEDIR)
shellcode  = shell32.s
NFLAGS     = -f elf -D ELF
CFLAGS     = -m32 
SHELL_TYPE = -D EMULATOR


all: assemble link
assemble:
	nasm $(NFLAGS) $(shellcode) $(INCLUDE) $(SHELL_TYPE) -o linkme.o
	nasm $(shellcode) $(INCLUDE) $(SHELL_TYPE) -o shellcode
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

clean:
	rm -f linkme.o testShellcode shellcode

