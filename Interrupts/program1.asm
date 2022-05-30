.MODEL small
.STACK 1024

CR   EQU 0Dh
LF   EQU 0Ah
TERM EQU 24h

.DATA

interrupt_vector_1  WORD 0
interrupt_vector_2  WORD 0
value				WORD 0

input_size			BYTE 0
tmp					BYTE 0
other_counter		BYTE 0
prompt 				BYTE "Enter a number between 0 and 100 (Celcius): ", TERM
interrupt_call_str  BYTE "Custom interrupt called.", TERM
buffered_input 		BYTE 6 DUP(0)
convert_buffer		BYTE 6 DUP(0)

.CODE

; Returns the value in DL to make it
; simpler to print later on
B_To_A MACRO BYTE_VALUE
	local begin, end_

	MOV BX, OFFSET convert_buffer
	
	MOV CX, 0
	MOV AX, BYTE_VALUE
	begin:
		CMP AX, 10
		JL end_
		
		PUSH CX
		MOV CL, 10
		DIV CL
		POP CX
		
		ADD AH, 30h
		MOV SI, CX
		MOV [BX + SI], AH
		
		MOV AH, 0
		
		INC CX
		
		JMP begin
	end_:
	
	ADD AL, 30h
	MOV SI, CX
	MOV [BX + SI], AL
	
	INC CX

	MOV SI, CX
	MOV BYTE PTR [BX + SI], TERM
	
	; Re-order
	MOV tmp, CL
	
	MOV CX, 0
	begin_reorder:
		CMP CL, tmp
		JGE end_reorder
		
		MOV AX, 0
		MOV SI, CX
		MOV AL, BYTE PTR [BX + SI]
		
		PUSH AX
		
		INC CL
		
		JMP begin_reorder
	end_reorder:
	
	MOV CX, 0
	re:
		CMP CL, tmp
		JGE end_re
	
		POP AX
		MOV SI, CX
		MOV [BX + SI], AL
	
		INC CL
	
		JMP re
	end_re:
	
ENDM

A_To_B MACRO ASCII_ARRAY
	MOV BX, OFFSET ASCII_ARRAY
	ADD BX, BYTE PTR 2

	MOV AX, 0
	
	; Look through the string and convert it to a number
	MOV CX, 0
	scan:
		CMP CL, input_size
		JGE end_scan
		
		MOV CH, input_size
		DEC CH
		SUB CH, CL
		MOV AL, 1
		begin_exp:
			CMP CH, 0
			JLE end_exp
			
			; Need a register, save this one
			PUSH CX
			MOV CH, 10
			MUL CH
			POP CX
		
			DEC CH
		
			JMP begin_exp
		end_exp:
		
		; Store the exponent value
		MOV tmp, AL
		
		; Fetch value for multiplying, turn it into non-ascii
		MOV SI, CX
		MOV AL, [BX + SI]
		SUB AL, 30h
		
		MUL tmp
		
		ADD value, AX
		
		INC CL
		
		JMP scan
	end_scan:
ENDM

Print_CRLF MACRO
	MOV DL, CR
	MOV AH, 06h
	INT 21h
	
	MOV DL, LF
	MOV AH, 06h
	INT 21h
ENDM

Custom_Interrupt PROC NEAR
	Print_CRLF

	MOV DX, OFFSET interrupt_call_str
	MOV AH, 09h
	INT 21h
	
	Print_CRLF

	IRET
Custom_Interrupt ENDP

start:
	; Setup Program
	CLI
	MOV AX, @DATA
	MOV DS, AX
	XOR AX, AX
	MOV ES, AX
	STI
	
	; Fetch interrupt
	MOV AX, 3525h
	INT 21h
	MOV interrupt_vector_1, ES
	MOV interrupt_vector_2, BX
	
	; Replace with our interrupt
	MOV AX, 2523h
	MOV DX, OFFSET Custom_Interrupt
	MOV BX, DS
	MOV ES, BX
	MOV BX, CS
	MOV DS, BX
	
	INT 21h
	MOV BX, ES
	MOV DS, BX
	
	; Setup our input array
	MOV BX, OFFSET buffered_input
	MOV [BX], BYTE PTR 4
	
	; Print Prompt
	MOV DX, OFFSET prompt
	MOV AH, 09h
	INT 21h
	
	; Get buffered keyboard input
	MOV DX, OFFSET buffered_input
	MOV AH, 0Ah
	INT 21h

	; Zero CX, very important
	MOV CX, 0
	
	; Get length, traverse to end, then append $
	MOV BX, OFFSET buffered_input
	MOV CL, [BX + 1]
	MOV input_size, CL
	ADD CL, 2
	XOR CH, CH
	MOV SI, CX
	
	MOV [BX + SI], BYTE PTR TERM
	
	Print_CRLF
	
	; Print their input
	MOV DX, OFFSET buffered_input
	ADD DX, BYTE PTR 2
	MOV AH, 09h
	INT 21h
	
	Print_CRLF

	; Returns converted value in value
	A_To_B buffered_input

	; We now have their input in numeric form
	; Convert to Fahrenheit
	MOV AX, value
	MOV CX, 9
	MUL CX
	
	MOV CX, 5
	DIV CX
	
	ADD AX, 32
	
	; Print it
	B_To_A AX
	MOV DX, OFFSET convert_buffer
	MOV AH, 09h
	INT 21h
	
	; Call our custom interrupt
	INT 23h
exit:
	; Reset to original interrupt
	MOV AX, 2523h	
	MOV DX, interrupt_vector_2
	MOV BX, DS 					
	MOV ES, BX	
	MOV DS, interrupt_vector_1

	INT 21h							
	MOV BX, ES 					
	MOV DS, BX
	
	MOV AX, 4C00h
    INT 21h

END start