all: test

CFLAGS= -nostdlib -lc -D start -fPIE -pie
test:
	gcc s.c -m32 -c -o stage.o $(CFLAGS)
	gcc stage.o ../gs.o -o stage $(CFLAGS) 
	gcc s.c -m32 -c -o debug.o $(CFLAGS) -D start -D DEBUG
	gcc debug.o ../gs.o -o debug_stage $(CFLAGS) -D start -D DEBUG


clean:
	rm -rf stage.o stage debug_stage
