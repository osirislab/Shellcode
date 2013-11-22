all: stage
stage:
	gcc s.c -m32 -c -o stage.o
	gcc stage.o ../gs.o -o stage

clean:
	rm -rf stage.o stage