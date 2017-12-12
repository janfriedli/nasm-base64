all: encode

clean:
	rm *.o *~

encode: encode.o
	gcc -o encode encode.o
encode.o: encode.asm
	nasm -f elf64 -g -F dwarf encode.asm
