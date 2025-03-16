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


.text
.global main

.eqv fs0_a fs0
.eqv fs1_b fs1
.eqv fs2_c fs2


main:
	li a7, SYS_ReadFloat
	ecall
	fmv.s fs0_a, fa0
	li a7, SYS_ReadFloat
	ecall
	fmv.s fs1_b, fa0
	li a7, SYS_ReadFloat
	ecall
	fmv.s fs2_c, fa0
	
	fmul.s fs3, fs1_b, fs2_c
	jal pflags
	fdiv.s fs4, fs0_a, fs3
	jal pflags
	li a7, SYS_PrintFloat
	fmv.s fa0, fs4
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
EXIT:
	li a7, SYS_Exit
	ecall

pflags:
	li a7, SYS_PrintChar
	frflags t1
pflags.NX:
	andi t2, t1, 0x1
	beqz t2, pflags.UF
	li a0, 'N'
	ecall
	li a0, 'X'
	ecall
	li a0, '\n'
	ecall
pflags.UF:
	andi t2, t1, 0x2
	beqz t2, pflags.OF
	li a0, 'U'
	ecall
	li a0, 'F'
	ecall
	li a0, '\n'
	ecall
pflags.OF:
	andi t2, t1, 0x4
	beqz t2, pflags.DZ
	li a0, 'O'
	ecall
	li a0, 'F'
	ecall
	li a0, '\n'
	ecall
pflags.DZ:
	andi t2, t1, 0x8
	beqz t2, pflags.RET
	li a0, 'D'
	ecall
	li a0, 'Z'
	ecall
	li a0, '\n'
	ecall
pflags.RET:
	andi t1, t1, 0xfffffff0
	fsflags t1
	ret