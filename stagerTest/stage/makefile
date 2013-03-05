all: compile
compile:
	 gcc lolStage.c -o stage -static -std=c99 -fPIC -O3 -shared -Wl,-soname, pwnlib.so.1 -lc
clean:
	rm stage