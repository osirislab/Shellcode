CFLAGS=-g -m32 -std=c99 -Wall


all: mapper unmap test input other 

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

clean:
	rm -f mapper unmap test input.so other 
