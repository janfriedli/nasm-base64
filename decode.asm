;  Executable name : decode
;  Version         : v0.1.0
;  Created date    : 13/12/2017
;  Last update     : 13/12/2017
;  Modified by     : Jan Friedli, Dominik Meister
;  Description     : A base64 decoder

SECTION .bss				; Section containing uninitialized data

	BUFFERLENGTH EQU 4						; reserve 4 bytes for each char
	Buff	resb BUFFERLENGTH
	outputBuffer: resb 3

SECTION .data				; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64CharacterMap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 10
	inputMsg: db "Please enter anything you want to decode from base64: ", 10

SECTION .text			; Section containing code
	global main

main:
	nop			; No-ops for GDB

	Read:
		; Read the necessary data block
		mov rax, 3							; Specify sys_read call
		mov rbx, 0							; Specify File Descriptor 0: Standard Input
		mov rcx, Buff						; Pass offset of the buffer to read to
		mov rdx, BUFFERLENGTH		; Pass number of bytes to read at one pass
		int 80h									; Call sys_read to fill the buffer

		cmp rax, 0			; If eax=0, sys_read reached EOF on stdin
		je Done		; Jump If Equal (to 0, from compare)

		; logic goes here
		xor rcx, rcx
		xor rdx, rdx
		xor rsi, rsi
		mov edx, 0

		loopOverFourBytes:
		; loop over the base64 map to find the accroding position value
		xor rax, rax
		xor rbx, rbx
			findCharInMap:
				mov byte bl, [Buff + edx] ; get the char from the buffer
				mov byte al, [base64CharacterMap + ecx] ; get a character
				inc ecx	; inc counter
				cmp al, bl ; compare if both chars are the same
				jne findCharInMap

			shl esi, 6 ; move em to the left
			or esi, ecx ; mask the 6bits
			inc dl
			cmp dl, 5 ; compare if loop over +1 because we inc above
			jne loopOverFourBytes
		mov [outputBuffer], esi

		xor rax, rax
		mov edx, 64     ; number of bytes to write - one for each letter plus 0Ah (line feed character)
	 	mov ecx, outputBuffer    ; move the memory address of our message string into ecx
	 	mov ebx, 1      ; write to the STDOUT file
	 	mov eax, 4      ; invoke SYS_WRITE (kernel opcode 4)
	 	int 80h

		jmp Read				; Loop back and load file buffer again

	; All done! Let's end this party:
	Done:
		mov rax, 1		; Code for Exit Syscall
		mov rbx, 0		; Return a code of zero
		int 80H			; Make kernel call
