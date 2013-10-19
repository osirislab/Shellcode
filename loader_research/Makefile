all: mapper test input other

mapper: mapper.c
	gcc -g -std=c99 -Wall mapper.c -o mapper

unmap: unmap.c
	gcc -g -std=c99 -Wall unmap.c -o unmap

test: test.c
	gcc -g -std=c99 -Wall test.c -ldl -o test

input: input.c
	gcc -g -std=c99 -Wall -shared input.c -o input.so

other: other.c
	gcc -g -std=c99 -Wall -pie -static -Wl,-Bstatic -static-libgcc other.c -o other


clean:
	rm mapper unmap test input.so other
