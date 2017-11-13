all: base64

clean:
	rm *.o *~

base64: base64.o
	ld -o base64 base64.o
base64.o: base64.asm
	nasm -f elf64 -g -F stabs base64.asm
