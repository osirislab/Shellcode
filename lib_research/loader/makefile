#Evan Jensen
#Make template for testing shellcode
shellcode = loader.s
NFLAGS = elf
CFLAGS = -m32 


all: assemble link
assemble:
	nasm -f $(NFLAGS) $(shellcode) -o linkme.o
	nasm $(shellcode) -o shellcode
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

clean:
	rm -f linkme.o
	rm -f testShellcode
	rm -f shellcode
