.NOLIST
.386

EXTRN compute_b_proc:Near32

; Float value returned in EAX
computeB    MACRO   point_array_addr, n, m
	push EDX
	push EBX
	push ECX

		push WORD PTR m
		push WORD PTR n
		push point_array_addr

		call compute_b_proc
	
	pop ECX
	pop EBX
	pop EDX
ENDM

.LIST      