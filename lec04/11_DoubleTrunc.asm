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

.data
_10:		.double 10.0

.text
.global main


main:
	li a7, SYS_ReadDouble
	ecall
	li a7, SYS_ReadInt
	ecall
	jal trunc
	li a7, SYS_PrintDouble
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
EXIT:
	li a7, SYS_Exit
	ecall
	
# fa0: a
# a0:  n
# -> fa0
trunc:
	fld ft1, _10, t0
	fmv.d ft0, ft1
trunc.L1:
	li t1, 1
	beq a0, t1, trunc.L2
	addi a0, a0, -1
	fmul.d ft0, ft0, ft1
	j trunc.L1
trunc.L2:
	fmul.d fa0, fa0, ft0
	fcvt.w.d t0, fa0, rtz
	fcvt.d.w fa0, t0, rtz
	fdiv.d fa0, fa0, ft0
	ret