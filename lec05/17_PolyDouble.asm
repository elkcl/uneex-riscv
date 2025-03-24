.eqv SYS_PrintInt    1
.eqv SYS_PrintFloat  2
.eqv SYS_PrintDouble 3
.eqv SYS_PrintString 4
.eqv SYS_ReadInt     5
.eqv SYS_ReadFloat   6
.eqv SYS_ReadDouble  7
.eqv SYS_ReadString  8
.eqv SYS_Sbrk        9
.eqv SYS_Exit        10
.eqv SYS_PrintChar   11
.eqv SYS_ReadChar    12   # broken

.macro POLY(%arr, %nreg, %xreg)
	mv t1, %nreg
	fmv.d ft0, %xreg
	fmv.d ft3, ft0
	la t0, %arr
	fld ft1, (t0)
	addi t0, t0, 8
POLY_L1:
	beqz t1, POLY_L2
	addi t1, t1, -1
	fld ft2, (t0)
	fmul.d ft2, ft2, ft3
	fadd.d ft1, ft1, ft2
	fmul.d ft3, ft3, ft0
	addi t0, t0, 8
	j POLY_L1
POLY_L2:
	fmv.d %xreg, ft1
.end_macro