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
_1:		.double 1.0
_m1:		.double -1.0
eps:		.double 1e-10

.text
.global main

.eqv fs0_sum  fs0
.eqv fs1_curr fs1
.eqv fs2_cnt  fs2
.eqv fs3_m1   fs3
.eqv fs4_eps  fs4

main:
	li a7, SYS_ReadDouble
	ecall
	li a7, SYS_ReadInt
	ecall
	fcvt.d.w fs0_sum, zero
	fld fs1_curr, _1, t0
	fld fs2_cnt, _1, t0
	fld fs3_m1, _m1, t0
	fld fs4_eps, eps, t0
L1:
    # [DEBUG]
	#li a7, SYS_PrintDouble
	#fmv.d ft0, fa0
	#fmv.d fa0, fs0_sum
	#ecall
	#fmv.d fa0, ft0
	#li a7, SYS_PrintChar
	#mv t1, a0
	#li a0, '\n'
	#ecall
	#mv a0, t1
	# [/DEBUG]
	fadd.d fs0_sum, fs0_sum, fs1_curr
	fmul.d fs1_curr, fs1_curr, fs3_m1
	fmul.d fs1_curr, fs1_curr, fa0
	fmul.d fs1_curr, fs1_curr, fa0
	fdiv.d fs1_curr, fs1_curr, fs2_cnt
	fsub.d fs2_cnt, fs2_cnt, fs3_m1
	fdiv.d fs1_curr, fs1_curr, fs2_cnt
	fsub.d fs2_cnt, fs2_cnt, fs3_m1
	fabs.d ft0, fs1_curr
	flt.d t1, ft0, fs4_eps
	beqz t1, L1
	
	fmv.d fa0, fs0_sum
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