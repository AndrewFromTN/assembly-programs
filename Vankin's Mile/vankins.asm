.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE io.h
INCLUDE debug.h

BUFFER_SIZE  EQU  08h
cr	  		 EQU  0Dh
lf			 EQU  0Ah

.STACK 4096

.DATA
MatrixWidth		WORD 0
MatrixHeight	WORD 0
CurrMatrixX		WORD 0
CurrMatrixY		WORD 0
Below			WORD 0
Right			WORD 0

currentVal		WORD 0
tmpXVal			WORD 0
tmpYVal			WORD 0

tmpCounter		WORD 0

Matrix			WORD 100 DUP(0)
MSize			WORD 0

tmp				BYTE  13 DUP(0)
crlf			BYTE cr, lf, 0

Directions		BYTE 100 DUP(0)


getElement  MACRO  matrix_addr, row, col, loc
	LEA EBX, matrix_addr
	
	MOV EAX, 0
	
	MOV AX, row
	MUL MatrixWidth
	
	MOV CX, 2
	MUL CX
	
	ADD EBX, EAX
	
	MOV EAX, 0
	MOV WORD PTR AX, col
	MUL CX
	
	ADD EBX, EAX
		
	MOV EBX, [EBX]
	MOV loc, BX
ENDM

setElement  MACRO  matrix_addr, row, col, value
	LEA EBX, matrix_addr
	
	MOV EAX, 0
	
	MOV AX, row
	MUL MatrixWidth
	
	MOV CX, 2
	MUL CX
	
	ADD EBX, EAX
	
	MOV EAX, 0
	MOV WORD PTR AX, col
	MUL CX
	
	ADD EBX, EAX
		
	MOV AX, value
	MOV [EBX], AX
ENDM

myInput  MACRO  dest, _length
	input dest, _length

	ATOI dest
	MOV dest, AX
ENDM

myOutput  MACRO  value
	ITOA tmp, value
    output tmp
ENDM

printMatrix  MACRO  matrix_addr
	local outerLoop, endOuter, outputValue
	
	LEA EBX, matrix_addr
	MOV AX, MatrixWidth
	MUL MatrixHeight
	MOV CX, AX
	MOV DX, 0

	outerLoop:
		CMP CX, 0
		JLE endOuter

		CMP DX, MatrixWidth
		JL outputValue
		
		output crlf
		MOV DX, 0
		
		outputValue:
			myOutput [EBX]
			
		INC DX
		
		ADD EBX, 2
		
		DEC CX
		
		JMP outerLoop
	endOuter:
		output crlf
ENDM

loadMatrix  MACRO  
	local startLoop, endLoop
	
	MOV AX, MatrixWidth
	MUL MatrixHeight
	MOV CX, AX

	LEA EBX, Matrix
	
	startLoop:
		CMP CX, 0
		JLE endLoop

		myInput [EBX], BUFFER_SIZE
	
		ADD EBX, 2
	
		DEC CX
	
		JMP startLoop
	endLoop:
ENDM

printMatrixList  MACRO  matrix_addr
	local startLoop1, endLoop1
	
	MOV AX, MatrixWidth
	MUL MatrixHeight
	MOV CX, AX
	
	LEA EBX, matrix_addr
	
	startLoop1:
		CMP CX, 0
		JLE endLoop1
		
		outputW [EBX]
	
		ADD EBX, 2
	
		DEC CX
	
		JMP startLoop1
	endLoop1:
ENDM

calculateVankins  Macro input_matrix_addr
	local startYLoop, endYLoop, moveUpRow, startXLoop, endXLoop, addBelow, last, skip, addRight, finish
		
	; EBX actually still holds the address of the end of the array
	DEC CurrMatrixX
	DEC CurrMatrixY
	
	startYLoop:
		CMP CurrMatrixY, 0
		JL endYLoop
		
		startXLoop:
			MOV Below, 0
			MOV Right, 0
		
			CMP CurrMatrixX, 0
			JL endXLoop
			
			getElement input_matrix_addr, CurrMatrixY, CurrMatrixX, currentVal
			
			MOV AX, CurrMatrixY
			INC AX
			MOV tmpYVal, AX
			CMP AX, MatrixHeight
			JGE skip
			
			getElement input_matrix_addr, tmpYVal, CurrMatrixX, Below
			
			skip:
			MOV AX, CurrMatrixX
			INC AX
			MOV tmpXVal, AX
			CMP AX, MatrixWidth
			JGE last
			
			getElement input_matrix_addr, CurrMatrixY, tmpXVal, Right
			
			last:
			MOV AX, Right
			CMP Below, AX
			JGE addBelow
			
			addRight:
			MOV AX, Right
			ADD currentVal, AX
			
			JMP finish
			
			addBelow:
			MOV AX, Below
			ADD currentVal, AX
			
			finish:
			setElement input_matrix_addr, CurrMatrixY, CurrMatrixX, currentVal
			
			DEC CurrMatrixX
			
			JMP startXLoop
		endXLoop:
		
		MOV AX, MatrixWidth
		DEC AX
		MOV CurrMatrixX, AX
		
		DEC CurrMatrixY
		
		JMP startYLoop
	endYLoop:
		output crlf
		printMatrix input_matrix_addr
ENDM

printSolution MACRO input_matrix_addr
	local bo, e, f, r, b, s

	MOV AX, MatrixHeight
	MOV BX, MatrixWidth
	MOV MSize, BX
	ADD MSize, AX
	
	DEC MSize
	
	MOV CurrMatrixX, 0
	MOV CurrMatrixY, 0
	
	LEA EBX, Directions
	
	DEC MSize
	b:
		CMP MSize, 0
		JLE e
		
		MOV Below, 0
		MOV Right, 0
		
		PUSH EBX
		getElement input_matrix_addr, CurrMatrixY, CurrMatrixX, currentVal
		POP EBX
		
		MOV AX, CurrMatrixY
		INC AX
		MOV tmpYVal, AX
		CMP AX, MatrixHeight
		JGE s
		
		PUSH EBX
		getElement input_matrix_addr, tmpYVal, CurrMatrixX, Below
		POP EBX
		
		s:
		MOV AX, CurrMatrixX
		INC AX
		MOV tmpXVal, AX
		CMP AX, MatrixWidth
		JGE last
		
		PUSH EBX
		getElement input_matrix_addr, CurrMatrixY, tmpXVal, Right
		POP EBX
		
		last:
		MOV AX, Right
		CMP Below, AX
		JG bo
		JE e
		
		r:
		MOV [EBX], WORD PTR 'r'
		INC CurrMatrixX

		JMP f
		
		bo:
		MOV [EBX], WORD PTR 'd'
		INC CurrMatrixY
		
		f:
		INC EBX
		DEC MSize

		JMP b
	e:
		MOV [EBX], WORD PTR 0
		
		output crlf
		output Directions
		output crlf
ENDM

.CODE
_start:

	myInput MatrixWidth, BUFFER_SIZE
	myInput MatrixHeight, BUFFER_SIZE
	
	; I get a mysterious crash if I try to read in height first, so I have to do this trick
	MOV AX, MatrixWidth
	MOV BX, MatrixHeight
	MOV MatrixHeight, AX
	MOV MatrixWidth, BX

	MOV AX, MatrixWidth
	MOV CurrMatrixX, AX
	
	MOV AX, MatrixHeight
	MOV CurrMatrixY, AX
	
	loadMatrix
	printMatrix Matrix
	
	calculateVankins Matrix
	printSolution Matrix
	
	output crlf
	
	INVOKE ExitProcess, 0

PUBLIC _start

END

