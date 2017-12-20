all: encode decode

clean:
	rm *.o *~

encode: encode.o
	gcc -o encode encode.o
encode.o: encode.asm
	nasm -f elf64 -g -F dwarf encode.asm

decode: decode.o
	ld -o decode decode.o
decode.o: decode.asm
	nasm -f elf64 -g -F dwarf decode.asm
