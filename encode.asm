;  Executable name : encode
;  Version         : v0.1.0
;  Created date    : 14/11/2017
;  Last update     : 14/11/2017
;  Author          : Jeff Duntemann
;  Modified by     : Jan Friedli, Dominik Meister
;  Date modification: 14/11/2017
;  Description     : A base64 encoder

SECTION .bss							; Section containing uninitialized data
	BUFFERLENGTH EQU 3			; reserve 3 bytes which will be processed ad 6bit * 4
	Buff	resb BUFFERLENGTH
	res: resb 64						; the buffer used to present the results

SECTION .data				; Section containing initialised data
	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	placeHolder: db "=" ; the placeolder sign

SECTION .text		; Section containing code
	global _start ; linker entry point

_start:
	nop						; No-ops for GDB
	xor rbp, rbp ; cleanup

	; the main reading loop
	Read:
		; Read the necessary data block
		mov rax, 3							; Specify sys_read call
		mov rbx, 0							; Specify File Descriptor 0: Standard Input
		mov rcx, Buff						; Pass offset of the buffer to read to
		mov rdx, BUFFERLENGTH		; Pass number of bytes to read at one pass
		int 80h									; Call sys_read to fill the buffer

		cmp rax, 0	; If eax=0, sys_read reached EOF on stdin
		je Done			; Jump If Equal (to 0, from compare)
		cmp rax, 1	; If rax is 1 we have Start of Heading which we ignore
		je Done			; Jump If Equal (to 0, from compare)

		; Fill the data for further processing and handle new line feed
		mov byte bh, [Buff] 	; load buff at pos o
		call bhigh
		mov byte bl, [Buff+1] ; load buff at pos + 1
		call blow
		shl rbx, 16
		mov byte bh, [Buff+2] ; load buff at pos + 2
		call bhigh
		mov [Buff], rax 			; save rax into Buffer

		; First 6 Bits
		mov rdx, rbx													; copy value
		call encodeShifting										; call shifting fuction
		mov [res], al 												; save first result in output buffer

		; 6-12 Bits
		mov rdx, rbx 													; copy value
		call encodeShifting										; call shifting fuction
		mov [res+1], al												; save second result in output buffer

		; 12-18 Bits
		mov rdx, rbx						; copy value
		call encodeShifting			; call shifting fuction
		call testForPlaceholder	; call plaholder testing function

		cmp rbp, 1							; if we have a placeholder dont print an A char
		je noAChar							; so we simply jump over it
		mov [res+2], al					; save third result in output buffer
		noAChar:

		; Last 6 bits
		mov rdx, rbx                          ; copy value
		call encodeShifting										; call shifting fuction
		call testForPlaceholder								; call plaholder testing function
		cmp rbp, 2 														; jump over the add to result since we don't want to print an A
		je noSecondAChar
		cmp rbp, 1 														; same here but in the case we only have one placeholder
		je noSecondAChar
		mov [res+3], al												; save third result in output buffer
		noSecondAChar:

		; Write the corresponding value to stdout:
		mov rax, 4		; Specify sys_write call
		mov rbx, 1		; Specify File Descriptor 1: Standard output
		mov rdx, 4		; specify how many bytes to print
		mov rcx, res	; Pass offset of line string
		int 80h				; Make kernel call to display line string
		jmp Read			; Loop back and load file buffer again


	testForPlaceholder:
		cmp rdx, 0 		; compare if we have 0 so we need print a placeholder
		jne jumpOver 	; don't print placeholder if we don't need it
		inc rbp				; inc placholder counter
		jumpOver:
		ret						; return to caller

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

	; does the actual encodeShiftinging
	encodeShifting:
		shl rbx, 38 		; Move the finished 6 Bits away
		shr rbx, 32			; Sets the bits back to the right place
		shr rdx, 26
		mov byte al, [base64Charactermap+rdx] ; get the corresponding character in the map
		ret ; return to caller

	printPlaceholders:
		cmp rbp, 0 									; if we have placeHolders to print do that in a loop
		je noPlaceholder
				dec rbp									; decrement the placholder counter
				mov eax, 4							; std_out
				mov ebx, 1							; Specify File Descriptor 1: Standard output
				mov edx, 1							; specify how many bytes to print
				mov ecx, placeHolder		; Pass placeholder sign
				int 80h									; print it
				call printPlaceholders	; recursive call until theres nothing left to print
		noPlaceholder:
		ret 												; return to caller

	; All done! Let's end this party:
	Done:
		call printPlaceholders	; print the remaining placeholders
		mov rax, 1							; Code for Exit Syscall
		mov rbx, 0							; Return a code of zero
		int 80H									; Make kernel call
