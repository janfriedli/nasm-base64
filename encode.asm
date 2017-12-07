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
	var1: resb 64
	res: resb 64
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

	;; Some cleaning 
	xor rax, rax
	xor rsi, rsi
	xor rdi, rdi
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx

	;; Fill the data for further processing
	mov byte bh, [var1]
	mov byte bl, [var1+1]
	shl rbx, 16
	mov byte bh, [var1+2]

	;; First 6 Bits
	mov rdx, rbx
	shl rbx, 38 		;Move the finished 6 Bits away
	shr rbx, 32		;Sets the bits back to the right place
	shr rdx, 26
	mov byte al, [base64Charactermap+rdx]
	mov [res], al

	;; Next 6 Bits
	mov rdx, rbx
	shl rbx, 38
	shr rbx, 32
	shr rdx, 26
	mov byte al, [base64Charactermap+rdx]
	mov [res+1], al

	;; NeXT 6 Bits
	mov rdx, rbx
	shl rbx, 38
	shr rbx, 32
	shr rdx, 26
	mov byte al, [base64Charactermap+rdx]
	mov [res+2], al

	;; Last 6 bits
	mov rdx, rbx
	shl rbx, 38
	shr rbx, 32
	shr rdx, 26
	mov byte al, [base64Charactermap+rdx]
	mov [res+3], al
	
	
	;print the result
	mov rsi, res
	mov rdi, formatTypeOut	;Formattype for printf
	xor rax , rax
	call printf
