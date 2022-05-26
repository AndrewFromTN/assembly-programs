.386
.MODEL FLAT

INCLUDE float.h
INCLUDE io.h
INCLUDE debug.h

; Args
m					EQU  [EBP + 14] ; WORD size
n					EQU  [EBP + 12] ; WORD size
point_array_addr    EQU  [EBP + 8]  ; DWORD size

; Locals
numer     			EQU  [EBP - 4]  ; DWORD size
denom				EQU  [EBP - 8]  ; DWORD size

.CODE
compute_b_proc  PROC  NEAR32
	PUSH EBP
	MOV EBP, ESP

	PUSHD 0
	PUSHD 0
	
	PUSHF
	MOV EBX, point_array_addr
	
	MOV CX, n
	CMP CX, m
	JE base
	
	ADD WORD PTR m, 1
	PUSH WORD PTR m
	PUSH WORD PTR n
	PUSH point_array_addr
	CALL compute_b_proc

	MOV numer, EAX

	SUB WORD PTR m, 1
	SUB WORD PTR n, 1
	PUSH WORD PTR m
	PUSH WORD PTR n
	PUSH point_array_addr
	CALL compute_b_proc
	
	ADD WORD PTR n, 1
	
	MOV denom, EAX
	
	FLD REAL4 PTR denom
	FLD REAL4 PTR numer
	
	FSUBR
	FSTP REAL4 PTR numer

	XOR EAX, EAX
	MOV AX, n
	SHL AX, 3
	MOV n, AX

	XOR EAX, EAX
	MOV AX, m
	SHL AX, 3
	MOV m, AX
	FLD REAL4 PTR [EBX + EAX]

	XOR EAX, EAX
	MOV AX, n
	FLD REAL4 PTR [EBX + EAX]

	FSUBR
	FLD REAL4 PTR numer
	FDIVR
	FSTP REAL4 PTR numer

	MOV EAX, numer
	
	JMP finish
	
	base:
	XOR EAX, EAX
	MOV AX, n
	SHL AX, 3
	ADD AX, 4
	MOV EAX, [EBX + EAX]

	finish:	
	POPF

	MOV ESP, EBP
	POP EBP

	ret 8
compute_b_proc ENDP

END