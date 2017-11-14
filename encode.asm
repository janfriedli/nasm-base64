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

SECTION .bss										; Section containing uninitialized data

	BUFFERLENGTH EQU 6						; reserve 6 bits for each process step
	Buff	resb BUFFERLENGTH

SECTION .data										; Section containing initialised data

	; this map is used to get the base64 representation of the coresponding 6 bits.
	base64Charactermap:	db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	DumpLin:	db " 00 00 00 00 "
	DUMPLEN		EQU $-DumpLin
	FULLLEN		EQU $-DumpLin
	msg db 'Hello World!', 0Ah

SECTION .text			; Section containing code

;-------------------------------------------------------------------------
; PrintLine: 	Displays DumpLin to stdout
; UPDATED: 	4/15/2009
; IN: 		Nothing
; RETURNS:	Nothing
; MODIFIES: 	Nothing
; CALLS:	Kernel sys_write
; DESCRIPTION:	The hex dump line string DumpLin is displayed to stdout
; 		using INT 80h sys_write. All GP registers are preserved.

PrintLine:
	push rax		  ; Save all used registers
	push rbx		  ; Save all used registers
	push rcx		  ; Save all used registers
	push rdx		  ; Save all used registers
	mov eax,4	  ; Specify sys_write call
	mov ebx,1	  ; Specify File Descriptor 1: Standard output
	mov ecx,DumpLin	  ; Pass offset of line string
	mov edx,FULLLEN	  ; Pass size of the line string
	int 80h		  ; Make kernel call to display line string
	pop rdx		  ; Restore all caller's registers
	pop rcx		  ;
	pop rbx		  ;
	pop rax		  ;
	ret		  ; Return to caller

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
	push rdx	  ; Save caller's EDXh
	mov eax,3	  ; Specify sys_read call
	mov ebx,0	  ; Specify File Descriptor 0: Standard Input
	mov ecx,Buff	  ; Pass offset of the buffer to read to
	mov edx,BUFFERLENGTH	  ; Pass number of bytes to read at one pass
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

	call LoadBuff
	mov     edx, 6     ; number of bytes to write - one for each letter plus 0Ah (line feed character)
  mov     ecx, Buff     ; move the memory address of our message string into ecx
  mov     ebx, 1      ; write to the STDOUT file
  mov     eax, 4      ; invoke SYS_WRITE (kernel opcode 4)
  int     80h

Exit:	mov eax,1		; Code for Exit Syscall
	mov ebx,0		; Return a code of zero
	int 80H			; Make kernel call
