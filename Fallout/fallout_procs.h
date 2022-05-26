.NOLIST

EXTRN numCharMatchesProc:NEAR32
EXTRN swap_proc:NEAR32 

numCharMatches  MACRO length, src1, src2, xtra
	IFB <length>
		.ERR <"Missing argument in numCharMatches">
	ELSEIFB <src1>
		.ERR <"Missing argument in numCharMatches">
	ELSEIFB <src2>
		.ERR <"Missing argument in numCharMatches">
	ELSEIFNB <xtra>
		.ERR <"Extra argument in numCharMatches">
	ENDIF
		
	PUSH ESI
	PUSH EDI
	;PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH EDX
		
	PUSH length
	PUSH src2
	PUSH src1
	
	call numCharMatchesProc

	POP EDX
	POP ECX
	POP EBX
	;POP EAX
	POP EDI
	POP ESI
ENDM

swap  MACRO length, src1, src2, xtra
	IFB <length>
		.ERR <"Missing argument in numCharMatches">
	ELSEIFB <src1>
		.ERR <"Missing argument in swap">
	ELSEIFB <src2>
		.ERR <"Missing argument in swap">
	ELSEIFNB <xtra>
		.ERR <"Extra argument in swap">
	ENDIF

	PUSH ESI 
	PUSH EDI
	
	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH EDX
	
	PUSH length
	PUSH src2
	PUSH src1
	
	call swap_proc
	
	POP EDX
	POP ECX
	POP EBX
	POP EAX
	
	POP EDI
	POP ESI
ENDM

.NOLISTMACRO
.LIST