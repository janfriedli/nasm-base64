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
	var1: resb 16

SECTION .data										; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	inputMsg: db "Please enter anything you want encode in base64: ",0
	inputType: db "%s",0
	formatTypeOut: db "Encoded value is: %s", 10, 0
	formatGreet:    db "%s", 0	; The printf format, "\n",'0'



SECTION .text			; Section containing code
	extern scanf, printf
	global main

main:
	nop			; No-ops for GDB
	nop

	; greet the user and tell him what to do
	mov rsi, inputMsg
	mov rdi, formatGreet	;Formattype for printf
	xor rax , rax
	call printf

	; get the input string
	xor rax, rax
	mov rdi, inputType	;Input format
	mov rsi, var1	;Address of returnvalue
	call scanf ; read input that will be base46 encoded

	;print the result
	mov rsi, var1
	mov rdi, formatTypeOut	;Formattype for printf
	xor rax , rax
	call printf
