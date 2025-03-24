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

.macro VectorOp(%arr_a, %arr_b, %len, %op)
	addi sp, sp, -12
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	la s0, %arr_a
	la s1, %arr_b
	li s2, %len
VectorOp_L1:
	beqz s2, VectorOp_L2
	lw a0, (s0)
	lw a1, (s1)
	jal %op
	sw a0, (s0)
	addi s0, s0, 4
	addi s1, s1, 4
	addi s2, s2, -1
	j VectorOp_L1
VectorOp_L2:
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	addi sp, sp, 12
.end_macro