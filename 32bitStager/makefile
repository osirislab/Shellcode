#Evan Jensen
#Make template for testing shellcode
shellcode = mapper_payload.s
NFLAGS = elf
CFLAGS = -m32 

all: mapper_payload test_shellcode
assemble:
	nasm -f $(NFLAGS) $(shellcode) -o linkme.o
	nasm $(shellcode) -o shellcode
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

mapper_payload: mapper_payload.s
	nasm mapper_payload.s -o shellcode
	nasm mapper_payload.s -o mapper_payload_test
	cat stage >> mapper_payload_test

test_shellcode: test_shellcode.c
	gcc -m32 test_shellcode.c -o test_shellcode




clean:
	rm linkme.o
	rm testShellcode
	rm shellcode
