.eqv SYS_PrintInt  1
.eqv SYS_ReadInt   5
.eqv SYS_Exit      10
.eqv SYS_PrintChar 11

.data
arr:
	.space 128
res:
	.space 128

.text
.global main

main:
	la t0, arr
	li t1, 32
L1:
	beqz t1, L2
	addi t1, t1, -1
	li a7, SYS_ReadInt
	ecall
	sw a0, (t0)
	addi t0, t0, 4
	j L1
L2:
	la a0, res
	la a1, arr
	la a2, arr
	addi a2, a2, 64
	li a3, 16
	jal join
	mv t0, a0
	li t1, 32
L3:
	beqz t1, EXIT
	addi t1, t1, -1
	lw a0, (t0)
	addi t0, t0, 4
	li a7, SYS_PrintInt
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
	j L3
EXIT:
	li a7, SYS_Exit
	ecall
	

# a0: res  (int[2*n])
# a1: arr1 (int[n])
# a2: arr2 (int[n])
# a3: n    (int)
# ->  res  (int[2*n])
join:
	mv t0, a0
	mv t1, a1
	mv t2, a2
	li t3, 4
	mul a3, a3, t3
	add a1, a1, a3
	add a2, a2, a3
join.L1:
	beq t1, a1, join.A1_EMPTY
	beq t2, a2, join.A2_EMPTY
	lw t3, (t1)
	lw t4, (t2)
	bgt t3, t4, join.L1.T4
	sw t3, (t0)
	addi t0, t0, 4
	addi t1, t1, 4
	j join.L1
join.L1.T4:
	sw t4, (t0)
	addi t0, t0, 4
	addi t2, t2, 4
	j join.L1
join.A1_EMPTY:
	beq t2, a2, join.RET
	lw t4, (t2)
	sw t4, (t0)
	addi t0, t0, 4
	addi t2, t2, 4
	j join.A1_EMPTY
join.A2_EMPTY:
	beq t1, a1, join.RET
	lw t3, (t1)
	sw t3, (t0)
	addi t0, t0, 4
	addi t1, t1, 4
	j join.A2_EMPTY
join.RET:
	ret