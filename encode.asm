;  Executable name : encode
;  Version         : v0.1.0
;  Created date    : 14/11/2017
;  Last update     : 14/11/2017
;  Author          : Jeff Duntemann
;  Modified by     : Jan Friedli, Dominik Meister
;  Date modification: 14/11/2017
;  Description     : A base64 encoder

SECTION .bss				; Section containing uninitialized data

	BUFFERLENGTH EQU 3						; reserve 3 bytes which will be processed ad 6bit * 4
	Buff	resb BUFFERLENGTH
	res: resb 64

SECTION .data				; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	inputMsg: db "Please enter anything you want to encode in base64: ", 10
	inputType: db "%s"
	placeHolder: db "="
	formatTypeOut: db "%s", 10
	formatGreet:    db "%s" ; The printf format

SECTION .text			; Section containing code

	extern scanf, printf
	global main

main:
	nop			; No-ops for GDB

	; ; greet the user and tell him what to do
	; mov rsi, inputMsg
	; mov rdi, formatGreet	;Formattype for printf
	; xor rax , rax
	; call printf

	Read:
		; Read the necessary data block
		mov eax, 3		; Specify sys_read call
		mov ebx, 0		; Specify File Descriptor 0: Standard Input
		mov ecx, Buff		; Pass offset of the buffer to read to
		mov edx, BUFFERLENGTH		; Pass number of bytes to read at one pass
		int 80h			; Call sys_read to fill the buffer

		mov ebp,eax		; Save # of bytes read from file for later
		cmp eax,0		; If eax=0, sys_read reached EOF on stdin
		je Done			; Jump If Equal (to 0, from compare)

		; Some cleaning
		xor rsi, rsi
		xor rdi, rdi
		xor rbx, rbx
		xor rcx, rcx
		xor rdx, rdx

		; Fill the data for further processing
		mov byte bh, [Buff]
		mov byte bl, [Buff+1]
		shl rbx, 16
		mov byte bh, [Buff+2]

		; First 6 Bits
		mov rdx, rbx
		shl rbx, 38 		; Move the finished 6 Bits away
		shr rbx, 32		; Sets the bits back to the right place
		shr rdx, 26
		mov byte al, [base64Charactermap+rdx]
		mov [res], al

		; Next 6 Bits
		mov rdx, rbx
		shl rbx, 38
		shr rbx, 32
		shr rdx, 26
		mov byte al, [base64Charactermap+rdx]
		mov [res+1], al

		; Next 6 Bits
		mov rdx, rbx
		shl rbx, 38
		shr rbx, 32
		shr rdx, 26
		call testForPlaceholder
		mov byte al, [base64Charactermap+rdx]
		mov [res+2], al

		; Last 6 bits
		mov rdx, rbx
		shl rbx, 38
		shr rbx, 32
		shr rdx, 26
		call testForPlaceholder
		mov byte al, [base64Charactermap+rdx]
		mov [res+3], al

		; Write the line of hexadecimal values to stdout:
		mov eax,4		; Specify sys_write call
		mov ebx,1		; Specify File Descriptor 1: Standard output
		mov edx, 64
		mov ecx, res		; Pass offset of line string
		int 80h			; Make kernel call to display line string
		jmp Read		; Loop back and load file buffer again


	testForPlaceholder:
		cmp rdx, 0 ; compare if we have 0 so we need print a placeholder
		jne jumpOver ; don't print placeholder if we don't need it
		mov eax,4		; Specify sys_write call
		mov ebx,1		; Specify File Descriptor 1: Standard output
		mov edx, 1
		mov ecx, placeHolder		; Pass placeholder sign
		int 80h
		jumpOver:
		ret


	; All done! Let's end this party:
	Done:
		mov eax,1		; Code for Exit Syscall
		mov ebx,0		; Return a code of zero
		int 80H			; Make kernel call
