;  Executable name : encode
;  Version         : v0.1.0
;  Created date    : 14/11/2017
;  Last update     : 14/11/2017
;  Author          : Jeff Duntemann
;  Modified by     : Jan Friedli, Dominik Meister
;  Date modification: 14/11/2017
;  Description     : A base64 encoder

SECTION .bss										; Section containing uninitialized data

	BUFFERLENGTH EQU 3						; reserve 3 bytes which will be processed ad 6bit * 4
	Buff	resb BUFFERLENGTH
	var1: resb 64
	res: resb 64
SECTION .data										; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	inputMsg: db "Please enter anything you want to encode in base64: ",0
	inputType: db "%s",0
	formatTypeOut: db "Encoded value is: %s", 10, 0
	formatGreet:    db "%s", 0	; The printf format



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

	Read:
		mov eax,3		; Specify sys_read call
		mov ebx,0		; Specify File Descriptor 0: Standard Input
		mov ecx,Buff		; Pass offset of the buffer to read to
		mov edx,BUFFERLENGTH		; Pass number of bytes to read at one pass
		int 80h			; Call sys_read to fill the buffer
		mov ebp,eax		; Save # of bytes read from file for later
		cmp eax,0		; If eax=0, sys_read reached EOF on stdin
		je Done			; Jump If Equal (to 0, from compare)

	Scan:
		;; Some cleaning
		xor rax, rax
		xor rsi, rsi
		xor rdi, rdi
		xor rbx, rbx
		xor rcx, rcx
		xor rdx, rdx

		;; Fill the data for further processing
		mov byte bh, [Buff]
		mov byte bl, [Buff+1]
		shl rbx, 16
		mov byte bh, [Buff+2]

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

		; Bump the buffer pointer to the next character and see if we're done:
		inc ecx		; Increment line string pointer
		cmp ecx,ebp	; Compare to the number of characters in the buffer
		jna Scan	; Loop back if ecx is <= number of chars in buffer
		jmp Read


	; All done! Let's end this party:
	Done:
		mov eax,1		; Code for Exit Syscall
		mov ebx,0		; Return a code of zero
		int 80H			; Make kernel call
