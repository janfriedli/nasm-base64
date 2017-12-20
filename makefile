all: encode decode

clean:
	rm *.o *~

encode: encode.asm
	nasm -f elf64 -g -F dwarf encode.asm
decode: decode.asm
	nasm -f elf64 -g -F dwarf decode.asm
