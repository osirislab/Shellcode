#Evan Jensen
#Make template for testing shellcode
shellcode = shell64.s
NFLAGS = elf

all: assemble link
assemble:
	nasm -f $(NFLAGS) $(shellcode) -o linkme.o
	nasm $(shellcode) -o shellcode
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

clean:
	rm linkme.o
	rm testShellcode
	rm shellcode
