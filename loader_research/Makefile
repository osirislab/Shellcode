CFLAGS=-g -m32 -std=c99 -Wall


all: mapper unmap test input other mapper_payload

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
	nasm -f elf mapper_payload.s -o mapper_payload.o
	gcc $(CFLAGS) -o mapper_payload_test mapper_payload.o
	rm -f mapper_payload.o

clean:
	rm -f mapper unmap test input.so other mapper_payload_test
