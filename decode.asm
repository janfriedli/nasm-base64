;  Executable name : decode
;  Version         : v0.1.0
;  Created date    : 13/12/2017
;  Last update     : 13/12/2017
;  Modified by     : Jan Friedli, Dominik Meister
;  Description     : A base64 decoder

SECTION .bss				; Section containing uninitialized data

	BUFFERLENGTH EQU 3						; reserve 3 bytes which will be processed ad 6bit * 4
	Buff	resb BUFFERLENGTH
	res: resb 64

SECTION .data				; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	inputMsg: db "Please enter anything you want to encode in base64: ", 10
	formatGreet:    db "%s" ; The printf format
	placeHolder: db "="
	counter db 0

SECTION .text			; Section containing code

	extern scanf, printf
	global main

main:
	nop			; No-ops for GDB

	; greet the user and tell him what to do
	mov rsi, inputMsg
	mov rdi, formatGreet	;Formattype for printf
	xor rax , rax
	call printf
	xor r9, r9

	Read:
		; Read the necessary data block
		mov rax, 3							; Specify sys_read call
		mov rbx, 0							; Specify File Descriptor 0: Standard Input
		mov rcx, Buff						; Pass offset of the buffer to read to
		mov rdx, BUFFERLENGTH		; Pass number of bytes to read at one pass
		int 80h									; Call sys_read to fill the buffer

		mov rbp, rax		; Save # of bytes read from file for later
		cmp rax, 0			; If eax=0, sys_read reached EOF on stdin
		je Done				; Jump If Equal (to 0, from compare)
		cmp rax, 1			; If rax is 1 we have Start of Heading which we ignore
		je Done				; Jump If Equal (to 0, from compare)

		; Fill the data for further processing and handle new line feed
		mov byte bh, [Buff]
		call bhigh
		mov byte bl, [Buff+1]
		call blow
		shl rbx, 16
		mov byte bh, [Buff+2]
		call bhigh
		mov [Buff], rax

		; First 6 Bits
		mov rdx, rbx
		shl rbx, 38 		; Move the finished 6 Bits away
		shr rbx, 32			; Sets the bits back to the right place
		shr rdx, 26
		mov byte al, [base64Charactermap+rdx]
		mov [res], al

		; 6-12 Bits
		mov rdx, rbx
		shl rbx, 38
		shr rbx, 32
		shr rdx, 26
		mov byte al, [base64Charactermap+rdx]
		mov [res+1], al

		; 12-18 Bits
		mov rdx, rbx
		shl rbx, 38
		shr rbx, 32
		shr rdx, 26
		call testForPlaceholder
		cmp r9, 1
		je noAChar
		mov byte al, [base64Charactermap+rdx]
		mov [res+2], al
		noAChar:

		; Last 6 bits
		mov rdx, rbx
		shl rbx, 38
		shr rbx, 32
		shr rdx, 26
		call testForPlaceholder
		cmp r9, 2 ; jump over the add to result since we don't want to print an A
		je noSecondAChar
		cmp r9, 1 ; same here but in the case we only have one placeholder
		je noSecondAChar
		mov byte al, [base64Charactermap+rdx]
		mov [res+3], al
		noSecondAChar:

		; Write the corresponding value to stdout:
		mov rax, 4				; Specify sys_write call
		mov rbx, 1				; Specify File Descriptor 1: Standard output
		mov rdx, 64
		mov rcx, res		; Pass offset of line string
		int 80h					; Make kernel call to display line string
		jmp Read				; Loop back and load file buffer again


	testForPlaceholder:
		cmp rdx, 0 							; compare if we have 0 so we need print a placeholder
		jne jumpOver 						; don't print placeholder if we don't need it
		inc r9
		mov [counter], r9				; inc '=' counter
		jumpOver:
		ret

	blow:
		cmp bl, 10
		jne notBlow
		mov bl, 0
		notBlow:
		ret

	bhigh:
		cmp bh, 10
		jne notHigh
		mov bh, 0
		notHigh:
		ret

	printPlaceholders:
		mov r9, [counter]
		cmp r9, 0
		je noPlaceholder
				dec r9
				mov [counter], r9
				mov eax, 4								; std_out
				mov ebx, 1								; Specify File Descriptor 1: Standard output
				mov edx, 1
				mov ecx, placeHolder			; Pass placeholder sign
				int 80h
				call printPlaceholders
		noPlaceholder:
		ret

	; All done! Let's end this party:
	Done:
		call printPlaceholders
		mov rax, 1		; Code for Exit Syscall
		mov rbx, 0		; Return a code of zero
		int 80H			; Make kernel call
