
RUNTIMEDIR = ../include/runtime/
INCLUDEDIR = ../include/
INCLUDE    = -I $(INCLUDEDIR) -I $(RUNTIMEDIR)
CFLAGS     = -m32 $(INCLUDE)
SFLAGS     = -D INT80

TARGET=shell32.s

all: assemble  link

assemble: $(TARGET)
	nasm -f elf $(TARGET) $(INCLUDE) -o shellcode.o $(SFLAGS)
	nasm  $(TARGET) $(INCLUDE) -o shellcode $(SFLAGS)

link:  $(TARGET) 
	gcc shellcode.o $(CFLAGS) -o test_shellcode


clean:
	rm -f shellcode shellcode.o test_shellcode
