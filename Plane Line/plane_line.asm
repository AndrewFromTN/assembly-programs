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
planePoint1X	WORD ?
planePoint1Y 	WORD ?
planePoint1Z	WORD ?
planePoint2X	WORD ?
planePoint2Y	WORD ?
planePoint2Z	WORD ?
planePoint3X	WORD ?
planePoint3Y	WORD ?
planePoint3Z	WORD ?
linePoint1X		WORD ?
linePoint1Y		WORD ?
linePoint1Z		WORD ?
linePoint2X		WORD ?
linePoint2Y		WORD ?
linePoint2Z		WORD ?

crossProductX	WORD ?
crossProductY	WORD ?
crossProductZ   WORD ?

dotProduct		WORD ?

P2PX1			WORD ?
P2PY1			WORD ?
P2PZ1			WORD ?

P2PX			WORD ?
P2PY			WORD ?
P2PZ			WORD ?

aDenom			WORD ?
aXVal			WORD ?
aYVal			WORD ?
aZVal			WORD ?

NumX			WORD ?
NumY			WORD ?
NumZ			WORD ?

xVal			WORD ?
yVal			WORD ?
zVal			WORD ?

planeXPrompt	BYTE  "Enter the x-coordinate of the point on the plane: ", 0
planeYPrompt	BYTE  "Enter the y-coordinate of the point on the plane: ", 0
planeZPrompt	BYTE  "Enter the z-coordinate of the point on the plane: ", 0

lineXPrompt		BYTE  "Enter the x-coordinate of the point on the line: ", 0
lineYPrompt		BYTE  "Enter the y-coordinate of the point on the line: ", 0
lineZPrompt		BYTE  "Enter the z-coordinate of the point on the line: ", 0

crlf			BYTE  cr, lf, 0

LocationSet		BYTE  50 DUP(?)

TMP				BYTE  50 DUP(?)
RemainderValues	BYTE  6  DUP(?)

PrintLocation  MACRO  xcoordinate, ycoordinate, zcoordinate
	MOV LocationSet + 22, 0
	MOV LocationSet + 21, ')'
	ITOA LocationSet + 15, zcoordinate
	MOV LocationSet + 14, ','
	ITOA LocationSet + 8, ycoordinate
	MOV LocationSet + 7, ','
	ITOA LocationSet + 1, xcoordinate
	MOV LocationSet, '('
	
	OUTPUT LocationSet
	OUTPUT crlf
ENDM

PrintLocationWithDecimal  MACRO  xcoordinate, ycoordinate, zcoordinate
	MOV LocationSet + 35, 0
	MOV LocationSet + 30, ')'
	MOV AH, RemainderValues + 5
	MOV LocationSet + 29, AH
	MOV AH, RemainderValues + 4
	MOV LocationSet + 28, AH
	MOV LocationSet + 27, '.'
	ITOA LocationSet + 21, zcoordinate
	MOV LocationSet + 20, ','
	MOV AH, RemainderValues + 3
	MOV LocationSet + 19, AH
	MOV AH, RemainderValues + 2
	MOV LocationSet + 18, AH
	MOV LocationSet + 17, '.'
	ITOA LocationSet + 11, ycoordinate
	MOV LocationSet + 10, ','
	MOV AH, RemainderValues + 1
	MOV LocationSet + 9, AH
	MOV AH, RemainderValues
	MOV LocationSet + 8, AH
	MOV LocationSet + 7, '.'
	ITOA LocationSet + 1, xcoordinate
	MOV LocationSet, '('
	
	OUTPUT LocationSet
	OUTPUT crlf
ENDM

;  Second - First
Point2PointCalc  MACRO  P0x, P0y, P0z, Px, Py, Pz
	MOV AX, Px
	SUB AX, P0x
	MOV P2PX, AX

	MOV AX, Py
	SUB AX, P0y
	MOV P2PY, AX
	
	MOV AX, Pz
	SUB AX, P0z
	MOV P2PZ, AX
ENDM

NormalPlaneCalc  MACRO  x1, y1, z1, x2, y2, z2, x3, y3, z3
	Point2PointCalc x1, y1, z1, x2, y2, z2
	MOV AX, P2PX
	MOV P2PX1, AX
	MOV AX, P2PY
	MOV P2PY1, AX
	MOV AX, P2PZ
	MOV P2PZ1, AX
	
	Point2PointCalc x1, y1, z1, x3, y3, z3
	CrossProductCalc P2PX1, P2PY1, P2PZ1, P2PX, P2PY, P2PZ	  ; n
	
	Point2PointCalc linePoint1X, linePoint1Y, linePoint1Z, linePoint2X, linePoint2Y, linePoint2Z
	DotProductCalc crossProductX, crossProductY, crossProductZ, P2PX, P2PY, P2PZ	
	
	MOV AX, dotProduct
	MOV aDenom, AX
	
	Point2PointCalc linePoint1X, linePoint1Y, linePoint1Z, x1, y1, z1
	DotProductCalc crossProductX, crossProductY, crossProductZ, P2PX, P2PY, P2PZ
	
	Point2PointCalc linePoint1X, linePoint1Y, linePoint1Z, linePoint2X, linePoint2Y, linePoint2Z

Division:

	MOV AX, dotProduct
	IMUL AX, P2PX
	MOV NumX, AX
	
	MOV AX, dotProduct
	IMUL AX, P2PY
	MOV NumY, AX
	
	MOV AX, dotProduct
	IMUL AX, P2PZ
	MOV NumZ, AX
	
	MOV AX, aDenom
	IMUL AX, linePoint1X
	ADD NumX, AX
	
	MOV AX, aDenom
	IMUL AX, linePoint1Y
	ADD NumY, AX
	
	MOV AX, aDenom
	IMUL AX, linePoint1Z
	ADD NumZ, AX	

	
	MOV AX, NumX
	CWD
	IDIV aDenom
	MOV aXVal, AX
	
	IMUL DX, 100
	
	MOV AX, DX
	CWD
	IDIV aDenom
	MOV xVal, AX

	MOV AX, numY
	CWD
	IDIV aDenom
	MOV aYVal, AX
	
	IMUL DX, 100
	
	MOV AX, DX
	CWD
	IDIV aDenom
	MOV yVal, AX

	MOV AX, numZ
	CWD
	IDIV aDenom
	MOV aZVal, AX

	IMUL DX, 100
	
	MOV AX, DX
	CWD
	IDIV aDenom
	MOV zVal, AX

	MOV dx, 0
	MOV ax, zVal
	cwd
	xor ax, dx
	sub ax, dx
	
	MOV zVal, ax
	
FormatDecimals:
	
	ITOA TMP, zVal
	MOV AH, TMP + 5
	MOV RemainderValues + 5, AH
	MOV AH, TMP + 4
	MOV RemainderValues + 4, AH
	
	ITOA TMP, yVal
	MOV AH, TMP + 5
	MOV RemainderValues + 3, AH
	MOV AH, TMP + 4
	MOV RemainderValues + 2, AH
	
	ITOA TMP, xVal
	MOV AH, TMP + 5
	MOV RemainderValues + 1, AH
	MOV AH, TMP + 4
	MOV RemainderValues, AH
	
	PrintLocationWithDecimal aXVal, aYVal, aZVal
ENDM

CrossProductCalc  MACRO  a_x, a_y, a_z, b_x, b_y, b_z
	MOV CX, a_y		; Save the value, we're going to overwrite it
	
	MOV AX, a_y
	IMUL AX, b_z
	MOV BX, AX
	
	MOV AX, a_z
	IMUL AX, b_y

	SUB BX, AX		
	MOV crossProductX, BX
	
	MOV AX, a_z
	IMUL AX, b_x
	MOV BX, AX
	
	MOV AX, a_x
	IMUL AX, b_z	

	SUB BX, AX		
	MOV crossProductY, BX
	
	MOV AX, a_x
	IMUL AX, b_y
	MOV BX, AX
	
	IMUL CX, b_x	; CX holds original value of a_y

	SUB BX, CX
	MOV crossProductZ, BX
ENDM

DotProductCalc  MACRO a_x, a_y, a_z, b_x, b_y, b_z
	MOV AX, a_x
	IMUL AX, b_x
	MOV BX, AX
	
	MOV AX, a_y
	IMUL AX, b_y
	MOV CX, AX
	
	MOV AX, a_z
	IMUL AX, b_z
	
	ADD BX, AX
	ADD CX, BX
	
	MOV dotProduct, CX
ENDM

.CODE
_start:

	inputW planeXPrompt, planePoint1X
	outputW planePoint1X
	
	inputW planeYPrompt, planePoint1Y
	outputW planePoint1Y
	
	inputW planeZPrompt, planePoint1Z
	outputW planePoint1Z
	
	PrintLocation planePoint1X, planePoint1Y, planePoint1Z

	output crlf
	
	inputW planeXPrompt, planePoint2X
	outputW planePoint2X
	
	inputW planeYPrompt, planePoint2Y
	outputW planePoint2Y
	
	inputW planeZPrompt, planePoint2Z
	outputW planePoint2Z
	
	PrintLocation planePoint2X, planePoint2Y, planePoint2Z
	
	output crlf
	
	inputW planeXPrompt, planePoint3X
	outputW planePoint3X
	
	inputW planeYPrompt, planePoint3Y
	outputW planePoint3Y
	
	inputW planeZPrompt, planePoint3Z
	outputW planePoint3Z
	
	PrintLocation planePoint3X, planePoint3Y, planePoint3Z
	
	output crlf
	
	inputW lineXPrompt, linePoint1X
	outputW linePoint1X
	
	inputW lineYPrompt, linePoint1Y
	outputW linePoint1Y
	
	inputW lineZPrompt, linePoint1Z
	outputW linePoint1Z
	
	PrintLocation linePoint1X, linePoint1Y, linePoint1Z
	
	output crlf
	
	inputW lineXPrompt, linePoint2X
	outputW linePoint2X
	
	inputW lineYPrompt, linePoint2Y
	outputW linePoint2Y
	
	inputW lineZPrompt, linePoint2Z
	outputW linePoint2Z
	
	PrintLocation linePoint2X, linePoint2Y, linePoint2Z
	
	output crlf
	
	NormalPlaneCalc planePoint1X, planePoint1Y, planePoint1Z, planePoint2X, planePoint2Y, planePoint2Z, planePoint3X, planePoint3Y, planePoint3Z
	
	INVOKE ExitProcess, 0

PUBLIC _start

END

