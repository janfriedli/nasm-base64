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
	var1: resb 8

SECTION .data										; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	InputMsg: db "Please enter anything you want encode in base64: ",0
	InputType: db "%s",0
	FormattypeOut: db "%ld",10,0


SECTION .text			; Section containing code
	extern scanf, printf
	global main

main:
	nop			; No-ops for GDB
	nop

	xor rax, rax
	mov rdi, InputType	;Input format
	mov rsi, var1	;Address of returnvalue
	call scanf ; read input that will be base46 encoded
