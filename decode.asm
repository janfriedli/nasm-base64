;  Executable name : decode
;  Version         : v0.1.0
;  Created date    : 13/12/2017
;  Last update     : 13/12/2017
;  Modified by     : Jan Friedli, Dominik Meister
;  Description     : A base64 decoder

SECTION .bss				; Section containing uninitialized data

	BUFFERLENGTH EQU 4						; reserve 4 bytes for each char
	Buff	resb BUFFERLENGTH				; the buffer
	outputBuffer: resb 3					; output

SECTION .data				; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64CharacterMap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 10
	inputMsg: db "Please enter anything you want to decode from base64: ", 10

SECTION .text			; Section containing code
	global _start

_start:
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
		cmp rax, 1			; If eax=1 start of header ignore that
		je Done		; Jump If Equal (to 0, from compare)

		xor rsi, rsi ; clean result every round
		xor rdx, rdx ; clean char counter

		; find first char and shift it into the result
		call findCharInMap
		shl ecx, 18 ; get first 6 bit
		add esi, ecx ; add them to buffer

		; second
		call findCharInMap
		shl ecx, 12 ; get second 6 bit
		add esi, ecx ; add them to buffer

		; third
		call findCharInMap
		shl ecx, 6	; get again 6bits
		add esi, ecx ; add them to buffer

		; and last one
		call findCharInMap
		add esi, ecx ; add last bits to buffer, no shifting needed

		; split the 24-bit number into the original three 8-bit (ASCII) characters
		xor rax, rax ; clean the hell out of it
		mov rax, rsi ; load rsi into a temp register
		shr rax, 16 ; shift 16bit to get the first 8 bit
		and rax, 255	; and to get the ascii representation
		mov [outputBuffer], rax

		xor rax, rax ; clean the hell out of it
		mov rax, rsi	; load rsi into a temp register
		shr rax, 8 ; shift 8bit to get the second 8 bit
		and rax, 255 ; and to get the ascii representation

		cmp rax, 30	; ascii 31 is before our range of characters we want to print, so ignore it
		jne noDoublePlaceholder ;check if we have to ignore the next lines
		xor rax, rax	; reset rax so we print a clean 0 and nothing elese
		jmp noPlaceholder ; if we have two placeholders dont print 0 twice
		noDoublePlaceholder:
		mov [outputBuffer+1], rax ; set ascii value into output buffer

		xor rax, rax ; clean the hell out of it
		mov rax, rsi ; load rsi into a temp register
		and rax, 255 ; and to get the ascii representation BTW no shifting needed here
		cmp rax, 123 ; check if we have a placeholder
		jne noPlaceholder ; reset rax if we have a placholder
		xor rax, rax ; xor all the things
		noPlaceholder:
		mov [outputBuffer+2], rax ; set ascii value into output buffer

		xor rax, rax		; as usual
		mov rdx, 64     ; number of bytes to write - one for each letter plus 0Ah (line feed character)
	 	mov rcx, outputBuffer    ; move the memory address of our message string into ecx
	 	mov rbx, 1      ; write to the STDOUT file
	 	mov rax, 4      ; invoke SYS_WRITE (kernel opcode 4)
	 	int 80h

		xor rsi, rsi ; reset res buffer
		jmp Read ; restart the read loop

	; gets the reverse value of the map char
	findCharInMap:
		xor rax, rax
		xor rbx, rbx
		xor rcx, rcx
		afterClean:
			mov byte bl, [Buff + edx] ; get the char from the buffer
			mov byte al, [base64CharacterMap + ecx] ; get a character
			inc ecx	; inc counter
			cmp al, bl ; compare if both chars are the same
		jne afterClean
		dec ecx ; begins at zero so minus one to get the real resu
		inc edx ; inc to get the nex t
		ret ; return to caller

	; All done! Let's end this party
	Done:
		mov rax, 1		; Code for Exit Syscall
		mov rbx, 0		; Return a code of zero
		int 80h		; Make kernel call
