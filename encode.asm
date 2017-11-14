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
;    ld -o encode encode.o
;

SECTION .bss			; Section containing uninitialized data

	BUFFLEN EQU 6						; reserve 6 bits for each process step
	Buff	resb BUFFLEN

SECTION .data			; Section containing initialised data

; Here we have two parts of a single useful data structure, implementing
; the text line of a hex dump utility. The first part displays 16 bytes in
; hex separated by spaces. Immediately following is a 16-character line
; delimited by vertical bar characters. Because they are adjacent, the two
; parts can be referenced separately or as a single contiguous unit.
; Remember that if DumpLin is to be used separately, you must append an
; EOL before sending it to the Linux console.

DumpLin:	db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
DUMPLEN		EQU $-DumpLin
ASCLin:		db "|................|",10
ASCLEN		EQU $-ASCLin
FULLLEN		EQU $-DumpLin

; this map is used to get the base64 representation of the coresponding 6 bits.
base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

SECTION .text			; Section containing code

;-------------------------------------------------------------------------
; LoadBuff: 	Fills a buffer with data from stdin via INT 80h sys_read
; UPDATED: 	4/15/2009
; IN: 		Nothing
; RETURNS:	# of bytes read in EBP
; MODIFIES: 	ECX, EBP, Buff
; CALLS:	Kernel sys_write
; DESCRIPTION:	Loads a buffer full of data (BUFFLEN bytes) from stdin
;		using INT 80h sys_read and places it in Buff. Buffer
;		offset counter ECX is zeroed, because we're starting in
;		on a new buffer full of data. Caller must test value in
;		EBP: If EBP contains zero on return, we hit EOF on stdin.
;		Less than 0 in EBP on return indicates some kind of error.

LoadBuff:
	push rax	  ; Save caller's EAX
	push rbx	  ; Save caller's EBX
	push rdx	  ; Save caller's EDX
	mov eax,3	  ; Specify sys_read call
	mov ebx,0	  ; Specify File Descriptor 0: Standard Input
	mov ecx,Buff	  ; Pass offset of the buffer to read to
	mov edx,BUFFLEN	  ; Pass number of bytes to read at one pass
	int 80h		  ; Call sys_read to fill the buffer
	mov ebp,eax	  ; Save # of bytes read from file for later
	xor ecx,ecx	  ; Clear buffer pointer ECX to 0
	pop rdx		  ; Restore caller's EDX
	pop rbx		  ; Restore caller's EBX
	pop rax		  ; Restore caller's EAX
	ret		  ; And return to caller


GLOBAL _start

; ------------------------------------------------------------------------
; MAIN PROGRAM BEGINS HERE
;-------------------------------------------------------------------------
_start:
	nop			; No-ops for GDB
	nop

; Whatever initialization needs doing before the loop scan starts is here:
	xor esi,esi		; Clear total byte counter to 0
	call LoadBuff		; Read first buffer of data from stdin
	cmp ebp,0		; If ebp=0, sys_read reached EOF on stdin
		; Print the "leftovers" line
Exit:	mov eax,1		; Code for Exit Syscall
	mov ebx,0		; Return a code of zero
	int 80H			; Make kernel call
