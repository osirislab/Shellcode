
RUNTIMEDIR = ../include/runtime/
INCLUDEDIR = ../include/
INCLUDE    = -I $(INCLUDEDIR) -I $(RUNTIMEDIR)
CFLAGS= -m32 -nostdlib -lc -D start -fPIE -pie  $(INCLUDE)
DEBUG_FLAGS= -m32 -lc -fPIE -pie -D DEBUG  $(INCLUDE)
TARGET=stage.c

all: compile debug_compile

assemble: $(RUNTIMEDIR)gs.s
	nasm -f elf $(RUNTIMEDIR)gs.s -o gs.o

compile:   assemble $(TARGET) 
	gcc $(TARGET) -c -o stage.o $(CFLAGS)
	gcc stage.o gs.o -o stage $(CFLAGS)
	strip stage

debug_compile: assemble $(TARGET) 
	gcc $(TARGET) -c -o debug.o $(DEBUG_FLAGS)
	gcc debug.o gs.o -o debug_stage $(DEBUG_FLAGS)

clean:
	rm -f stage.o debug.o stage debug_stage gs.o
