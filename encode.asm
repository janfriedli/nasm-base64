;  Executable name : encode
;  Version         : v0.1.0
;  Created date    : 14/11/2017
;  Last update     : 14/11/2017
;  Author          : Jeff Duntemann
;  Modified by     : Jan Friedli
;  Date modification: 14/11/2017
;  Description     : A base64 encoder which takes a file as an argument and
; 									 returns the base64 representation of it
;
;  Build using these commands:
;    nasm -f elf64 -g -F stabs encode.asm
;    gcc -o encode encode.o
;

SECTION .bss										; Section containing uninitialized data

	BUFFERLENGTH EQU 6						; reserve 6 bytes for each process step
	Buff	resb BUFFERLENGTH

SECTION .data										; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	testString: db "testing" ; should become dGVzdGluZw==
	formatout: db "%d", 0 ; newline, nul terminator
	testMsg: db "The quieter we become the more we are able to hear",10,0


SECTION .text			; Section containing code

extern scanf, printf

global main

main:
	nop			; No-ops for GDB
	nop

	xor eax, eax
	mov eax, 122
	mov ebx, 63 ; mark 6 bits
 	and ebx, eax

Exit:	mov eax,1		; Code for Exit Syscall
	mov ebx,0		; Return a code of zero
	int 80H			; Make kernel call
