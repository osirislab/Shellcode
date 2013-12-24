#Evan Jensen
#Make template for testing shellcode
shellcode = mapper_payload.s
NFLAGS = elf
CFLAGS = -m32 
STAGE_LOC=../stage/

all: stage mapper_payload test_shellcode 
assemble:
	nasm -f $(NFLAGS) $(shellcode) -o linkme.o
	nasm $(shellcode) -o shellcode
link:
	gcc linkme.o -o testShellcode $(CFLAGS)

mapper_payload: mapper_payload.s
	nasm mapper_payload.s -o shellcode
	nasm mapper_payload.s -o mapper_payload_test
	nasm mapper_payload.s -o mapper_payload_test_raw


test_shellcode: test_shellcode.c
	gcc -m32 test_shellcode.c -o test_shellcode

stage:
	cd $(STAGE_LOC) && $(MAKE)

clean:
	rm -f linkme.o testShellcode shellcode


