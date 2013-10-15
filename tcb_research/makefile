OUTPUT=tcb

all: 
	nasm -f elf *.s
	gcc -m32 *.o -o $(OUTPUT) -lc -lpthread
 
clean:
	rm -f *.o
	rm -f $(OUTPUT)