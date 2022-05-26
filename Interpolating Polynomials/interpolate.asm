.386
.MODEL FLAT

INCLUDE float.h
INCLUDE io.h
INCLUDE debug.h
INCLUDE compute_bs.h

xval				EQU	 [EBP + 14] ; DWORD size
degree				EQU  [EBP + 12]	; WORD size
point_array_addr    EQU  [EBP + 8]  ; DWORD size

; Locals

inner_value		EQU  [EBP - 4]
b_value			EQU	 [EBP - 8]
final_value		EQU	 [EBP - 12]

.CODE
interpolate_proc  PROC  NEAR32
	PUSH EBP
	MOV EBP, ESP
	
	SUB ESP, 12		; Reserve space for locals
	
	PUSHF
	
	MOV final_value, REAL4 PTR 0
	
	MOV EBX, point_array_addr
	
	MOV CX, degree
	begin_loop:
		CMP CX, 0
		JLE end_loop

		MOV DX, CX
		begin_inner:
			CMP DX, 0
			JLE end_inner
			
			XOR EAX, EAX
			MOV AX, DX
			SUB AX, 1
			SHL AX, 3
					
			FLD REAL4 PTR [EBX + EAX]
			FLD REAL4 PTR xval			
			FSUBR
			
			CMP DX, degree
			JNE multiply
			
			set:
			FSTP REAL4 PTR inner_value
			
			JMP finish_inner_iter
			
			multiply:
			FLD REAL4 PTR inner_value
			FMUL
			FSTP REAL4 PTR inner_value
			
			finish_inner_iter:
			SUB DX, 1
			JMP begin_inner
		end_inner:
		
		computeB point_array_addr, CX, 0 ; Value returned in EAX
		MOV b_value, EAX

		FLD REAL4 PTR b_value
		FLD REAL4 PTR inner_value
		FMUL		
		
		FLD REAL4 PTR final_value
		FADD
		FSTP REAL4 PTR final_value 
	
		; bn(X - Xn)(X - Xn-1)...(X - X0)
	
		SUB WORD PTR degree, 1
		SUB CX, 1
		
		JMP begin_loop
	end_loop:

	; ADD B0
	computeB point_array_addr, 0, 0 ; Value returned in EAX
	MOV b_value, EAX
	
	FLD REAL4 PTR b_value
	FLD REAL4 PTR final_value
	FADD
	FSTP REAL4 PTR final_value

	MOV EAX, final_value
	
	finish:
	POPF
	
	MOV ESP, EBP
	POP EBP
	
	RET 10
interpolate_proc ENDP

END