.NOLIST      ; turn off listing
.386

EXTRN interpolate_proc : Near32

; Float value returned in EAX
interpolate  MACRO  point_array_name, degree, xval
	PUSH ECX
	PUSH EDX
	PUSH EBX
	
		PUSH REAL4 PTR xval
		PUSH WORD PTR degree

		LEA EBX, point_array_name
		PUSH EBX
		CALL interpolate_proc
		
	POP EBX
	POP EDX
	POP ECX
ENDM

.NOLISTMACRO ; suppress macro expansion listings
.LIST        ; begin listing