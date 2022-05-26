.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE io.h
INCLUDE debug.h
INCLUDE fallout_procs.h

CR	EQU 0Dh
LF  EQU 0Ah
MAX EQU 20d
LEN EQU 13d

.STACK 4096

.DATA
actualLEN		 DWORD 0
wordAdresses	 DWORD 20 DUP(0)
currIndex		 DWORD 0
currExactMatches DWORD 0
numCorrectWords	 DWORD 0
offset_			 DWORD 0
numWords		 DWORD 0
timesShifted     DWORD 0

numGuesses		 WORD 0

first			 BYTE 1

crlf			 BYTE  CR, LF, 0

strPrompt		 BYTE "Enter a string: ", 0
numberPrompt	 BYTE "The number of strings entered is: ", 0
testIndexPrompt  BYTE "Enter the index for the test password (1-based): ", 0
exactIndexPrompt BYTE "Enter the number of exact character matches: ", 0
words			 BYTE 1000 DUP(0)

currASCII		 BYTE 13 DUP(0)

readWords MACRO
	LOCAL start_loop, end_loop
	
	LEA EDI, words
	LEA EBX, wordAdresses

	MOV EAX, 0
	start_loop:
		output strPrompt
		input currASCII, LEN
		
		output currASCII
		output crlf
		
		CMP currASCII, 'x'
		
		JE end_loop
		
		LEA ESI, currASCII
		
		MOV ECX, DWORD PTR 0
		MOV CX, LEN
		SUB CX, 2
		
		MOV [EBX], EDI
		ADD EBX, 4		

		REP MOVSB

		INC EAX
		
		JMP start_loop
	end_loop:
		MOV [EDI], BYTE PTR 0
	
	MOV numWords, EAX
ENDM

print_pretty  MACRO
	LOCAL print_loop, end_print_loop

	MOV EAX, 0
	MOV EDX, 0
	print_loop:
		CMP EAX, numCorrectWords
		JGE end_print_loop
		
		MOV ECX, actualLEN
		MOV ESI, [EBX + EDX]
		LEA EDI, currASCII
		REP MOVSB
		
		MOV [EDI], BYTE PTR 0

		output currASCII
		output crlf
		
		INC EAX
		ADD EDX, 4
		
		JMP print_loop
	end_print_loop:
ENDM

get_and_output  MACRO
	output crlf
	output testIndexPrompt
	input currASCII, LEN
	output currASCII
	atod currASCII
	MOV currIndex, EAX
	output crlf

	output exactIndexPrompt
	input currASCII, LEN
	output currASCII
	atod currASCII
	MOV currExactMatches, EAX
	output crlf
	output crlf
ENDM

output_prompts  MACRO
	output crlf
	output testIndexPrompt
	MOV EAX, currIndex
	dtoa currASCII, EAX
	output currASCII
	output crlf

	output exactIndexPrompt
	MOV EAX, currExactMatches
	dtoa currASCII, EAX
	output currASCII
	output crlf
	output crlf
ENDM

.CODE
_start:
	readWords
	output crlf
	output numberPrompt
	dtoa currASCII, EAX
	output currASCII
	output crlf
	output crlf
	
	LEA EBX, wordAdresses
	
	MOV ECX, LEN
	SUB ECX, 2
	MOV actualLEN, ECX

	MOV EAX, numWords
	DEC EAX
	MOV numCorrectWords, EAX
	
	print_pretty ; Macro
	
	main_loop:
		CMP numGuesses, 4
		JG end_main_loop

		get_and_output ; Macro

		MOV ECX, 0
		MOV offset_, 0
		MOV timesShifted, 0
		innerloop:
			CMP ECX, numCorrectWords
			JG end_inner
			
			; Setup Offsets
			MOV EAX, currIndex
			DEC EAX
			ADD EAX, timesShifted
			IMUL EAX, DWORD PTR 4

			MOV EDX, ECX
			IMUL EDX, DWORD PTR 4
			
			;					; The looped word.  The chosen value.
			numCharMatches actualLEN, [EBX + EDX],  [EBX + EAX]	; Returns value in EAX

			; Check if we have a match
			CMP EAX, currExactMatches
			JNE not_equal

			CMP currIndex, 1
			JNE not_first
			
			CMP timesShifted, 0
			JNE not_first
			
			JMP shift
			
			not_first:
			
			; Shift if we are about to swap our chosen words
			MOV EAX, currIndex
			DEC EAX
			CMP offset_, EAX
			JL no_shift
			
			CMP currIndex, 1
			JNE shift

			CMP ECX, 0
			JNE shift
			
			JMP no_shift
			
			shift:
			
			ADD EAX, timesShifted
			IMUL EAX, DWORD PTR 4
			
			swap actualLEN, [EBX + EAX], [EBX + EAX + 4] ; Procedure call
			
			INC timesShifted
			
			no_shift:
			
			; Setup offsets
			MOV EDX, ECX
			IMUL EDX, DWORD PTR 4
			
			; Print the word, then swap it
			PUSH ECX
			MOV ECX, actualLEN
			MOV ESI, [EBX + EDX]
			LEA EDI, currASCII
			REP MOVSB

			MOV [EDI], BYTE PTR 0
			
			output currASCII
			output crlf
			POP ECX
			
			MOV EAX, offset_
			IMUL EAX, DWORD PTR 4
			
			;			  The found word  The first+number of found words word
			swap actualLEN, [EBX + EDX], [EBX + EAX]	; Procedure Call

			INC offset_
			
			not_equal:
			
			INC ECX
					
			JMP innerloop
		end_inner:
		
		MOV EAX, offset_
		MOV numCorrectWords, EAX
		
		CMP EAX, 1
		JLE end_main_loop
		
		not_found:
	
		INC numGuesses
		
		JMP main_loop
	end_main_loop:
	
	INVOKE ExitProcess, 0
PUBLIC _start

END