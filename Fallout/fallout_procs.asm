.386
.MODEL FLAT

INCLUDE io.h
INCLUDE debug.h

; Args

len  EQU [EBP + 16]
src2 EQU [EBP + 12]
src1 EQU [EBP + 8]

; Locals

; Returns the number of character matches between two strings

.CODE
numCharMatchesProc PROC NEAR32
	PUSH EBP
	MOV EBP, ESP

	PUSHF
	
	CLD
	
	MOV EAX, 0

	; Need to double dereference
	MOV ESI, src1
	MOV EDI, src2
	
	MOV ECX, len
	
	do_again:
	
	REPNE CMPSB
	
	JNE finish
	
	incFromLast:
	
	INC EAX
	
	CMP ECX, 0
	JLE finish
	
	JMP do_again
	
	finish:
	
	POPF
	
	MOV ESP, EBP
	POP EBP
	
	RET 12
numCharMatchesProc ENDP

swap_proc PROC NEAR32
	PUSH EBP
	MOV EBP, ESP
	
	PUSHF
	
	CLD
	
	MOV EAX, 0
	MOV ECX, 0

	; Save the address in EBX
	;MOV EBX, src2

	MOV EDI, src1
	MOV ESI, src2

	MOV ECX, len
	start_loop:

	MOV EBX, ESI
	
	; Mov byte from ESI to AL
	LODSB
	
	; Swap them around
	MOV ESI, EDI
	MOV EDI, EBX

	; Change the value
	MOVSB
	
	; Swap them back
	MOV EBX, EDI
	MOV EDI, ESI
	MOV ESI, EBX
	
	DEC EDI
	
	; Copy value out of AL
	STOSB
	
	LOOP start_loop
	
	MOV ESI, src1

	POPF
	MOV ESP, EBP
	POP EBP
	
	RET 12
swap_proc ENDP


END