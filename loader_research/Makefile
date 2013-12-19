CFLAGS=-g -m32 -std=c99 -Wall


all: mapper unmap test input other mapper_payload test_shellcode

mapper: mapper.c
	gcc $(CFLAGS) mapper.c -o mapper

unmap: unmap.c
	gcc $(CFLAGS) unmap.c -o unmap

test: test.c
	gcc $(CFLAGS) test.c -ldl -o test

input: input.c
	gcc $(CFLAGS) -shared -fPIC input.c -o input.so

other: other.c
	gcc $(CFLAGS) -pie -static -Wl,-Bstatic -static-libgcc other.c -o other

mapper_payload: mapper_payload.s
	nasm mapper_payload.s -o mapper_payload_test
	cat stage >> mapper_payload_test

test_shellcode: test_shellcode.c
	gcc -m32 test_shellcode.c -o test_shellcode

clean:
	rm -f mapper unmap test input.so other mapper_payload_test test_shellcode
