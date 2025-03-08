.eqv SYS_PrintInt  1
.eqv SYS_ReadInt   5
.eqv SYS_Sbrk      9
.eqv SYS_Exit      10
.eqv SYS_PrintChar 11

.eqv t0_N       t0
.eqv t1_arr     t1
.eqv t2_arr_end t2

.text
.global _start

_start:
	li a7, SYS_ReadInt
	ecall
	mv t0_N, a0
	li a1, 4
	mul a0, a0, a1
	li a7, SYS_Sbrk
	ecall
	mv t1_arr, a0
	mv t2_arr_end, a0
L1:
	beqz t0_N, L2
	addi t0_N, t0_N, -1
	li a7, SYS_ReadInt
	ecall
	li a1, 2
	rem a1, a0, a1
	bnez a1, L1_NEZ
	li a7, SYS_PrintInt
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
	j L1
L1_NEZ:
	sw a0, (t2_arr_end)
	addi t2_arr_end, t2_arr_end, 4
	j L1
L2:
	beq t1_arr, t2_arr_end, EXIT
	lw a0, (t1_arr)
	li a7, SYS_PrintInt
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
	addi t1_arr, t1_arr, 4
	j L2
EXIT:
	li a7, SYS_Exit
	ecall