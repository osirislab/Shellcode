#Evan Jensen
#Make template for testing shellcode

RUNTIMEDIR = ../include/runtime/
INCLUDEDIR = ../include/
INCLUDE    = -I $(INCLUDEDIR) -I $(RUNTIMEDIR)

shellcode  = r32.s
NFLAGS     = -f elf
SFLAGS     = -D INT80

CFLAGS = -m32

all: assemble link
assemble:
	nasm $(NFLAGS) $(shellcode) $(INCLUDE) $(SFLAGS) -o linkme.o
	nasm $(shellcode) $(INCLUDE) $(SFLAGS) -o shellcode
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

clean:
	rm -f linkme.o testShellcode shellcode

