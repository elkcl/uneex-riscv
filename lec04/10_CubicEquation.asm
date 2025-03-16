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
c:	  .space  8
d:	  .space  8
_2:   .double 2.0
_3:   .double 3.0
eps:  .double 1e-8

.text
.global main

.eqv fs0_x   fs0
.eqv fs1_eps fs1

main:
	li a7, SYS_ReadInt
	ecall
	fcvt.d.w ft0, a0
	fsd ft0, c, t0
	li a7, SYS_ReadInt
	ecall
	fcvt.d.w ft0, a0
	fsd ft0, d, t0
	
	fld ft2, _2, t0
	fld ft0, c, t0
	fabs.d ft0, ft0
	fdiv.d ft0, ft0, ft2
	fld ft1, d, t0
	fabs.d ft1, ft1
	fdiv.d ft1, ft1, ft2
	fmax.d fs0_x, ft0, ft1
	fld fs1_eps, eps, t0
L1:
	fmv.d fa0, fs0_x
	# [DEBUG]
	#li a7, SYS_PrintDouble
	#ecall
	#li a7, SYS_PrintChar
	#li a0, '\n'
	#ecall
	# [/DEBUG]
	call func
	fabs.d ft0, fa0
	flt.d t0, ft0, fs1_eps
	bnez t0, L2
	fmv.d ft0, fs0_x
	fmul.d ft0, ft0, ft0
	fld ft1, _3, t0
	fmul.d ft0, ft0, ft1
	fld ft1, c, t0
	fadd.d ft0, ft0, ft1
	fclass.d t0, ft0
	andi t0, t0, 0x18
	bnez t0, L1_nudge
	fdiv.d fa0, fa0, ft0
	fsub.d fs0_x, fs0_x, fa0
	j L1
L1_nudge:
	fadd.d fs0_x, fs0_x, fs1_eps
	j L1
L2:
	li a7, SYS_PrintDouble
	fmv.d fa0, fs0_x
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
EXIT:
	li a7, SYS_Exit
	ecall
	
# fa0:	x (double)
# ->		double
func:
	fmv.d ft0, fa0
	fmul.d fa0, ft0, ft0
	fmul.d fa0, fa0, ft0
	fld ft1, c, t0
	fmul.d ft0, ft0, ft1
	fadd.d fa0, fa0, ft0
	fld ft1, d, t0
	fadd.d fa0, fa0, ft1
	ret