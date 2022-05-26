.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE io.h
INCLUDE debug.h
INCLUDE float.h
INCLUDE interpolate.h
INCLUDE sort_points.h

BUFFER_SIZE  EQU  08h
cr	  		 EQU  0Dh
lf			 EQU  0Ah
q			 EQU  71h

.STACK 4096

.DATA
points			REAL4 100 DUP(0.f)
currVal			REAL4 0.f
tol 			REAL4 0.0000001f

xVal			REAL4 0.f
degree			WORD 0
numPoints		WORD 0

currASCII		BYTE 13 DUP(0.f)
crlf			BYTE  cr, lf, 0
prompt1			BYTE  "Enter the x-coordinate of the desired interpolated y: ", 0
prompt2			BYTE  "Enter the degree of the interpolating polynomial: ", 0
prompt3			BYTE  "You may enter up to 20 points, one at a time.", 0
prompt4			BYTE  "Input q to quit.", 0

myInput MACRO location
   input currASCII, 8
   atod currASCII
   MOV location, eax
ENDM

PrintList  MACRO ; For debugging, to make sure the offsets were right, etc.
	.LOCAL start_loop1, end_loop1

	LEA EBX, points
	
	MOV CX, 12
	start_loop1:
		CMP CX, 0
		JLE end_loop1
		
		ftoa [EBX], WORD PTR 4, WORD PTR 13, currASCII
		
		output currASCII
		output crlf
		
		ADD EBX, 4
	
		SUB CX, 1
	
		JMP start_loop1
	end_loop1:
ENDM

.CODE
_start:
	output prompt1
	input currASCII, 8
	atof currASCII, xVal
	output crlf
	output currASCII
	output crlf
	
	inputW prompt2, degree
	output crlf
	outputW degree
	output crlf
	
	output prompt3
	output crlf
	
	output prompt4
	output crlf
	
	LEA EBX, points
	
	start_loop:
		input currASCII, 8
		CMP currASCII, 'q'
		JE end_loop
		
		ADD numPoints, 1
		
		atof currASCII, currVal
		
		MOV EAX, currVal
		MOV [EBX], EAX
		
		output currASCII
		output crlf
		
		ADD EBX, 4
	
		JMP start_loop
	end_loop:
	
	output crlf
	
	MOV AX, numPoints
	SHR AX, 1
	MOV numPoints, AX
	
	sort_points points, xVal, tol, numPoints
	print_points points, numPoints
	
	output crlf
	
	;computeB points, degree, 0
	;ftoa EAX, WORD PTR 6, WORD PTR 13, text
	;output text
	
	interpolate points, degree, xVal
	
	ftoa EAX, WORD PTR 8, WORD PTR 13, text
	output text
	
	INVOKE ExitProcess, 0

PUBLIC _start

END


