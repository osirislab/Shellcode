all: test
stage:
	gcc s.c -m32 -c -o stage.o
	gcc stage.o ../gs.o -o stage

start:
	gcc s.c -m32 -c -o stage.o -D start --shared -fPIC
	gcc stage.o ../gs.o -o stage -D start --shared -fPIC

main:
	gcc s.c -m32 -c -o stage.o 
	gcc stage.o ../gs.o -o stage -Wl, --entry=main

test:
	gcc s.c -m32 -c -o stage.o -nostdlib -lc -D start -fPIE -pie
	gcc stage.o ../gs.o -o stage -nostdlib -lc -D start -fPIE -pie
	gcc s.c -m32 -c -o debug.o -nostdlib -lc -D start -fPIE -pie -D DEBUG
	gcc debug.o ../gs.o -o debug_stage -nostdlib -lc -D start -fPIE -pie -D DEBUG


clean:
	rm -rf stage.o stage