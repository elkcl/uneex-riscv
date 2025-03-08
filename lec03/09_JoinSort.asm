.eqv SYS_PrintInt  1
.eqv SYS_ReadInt   5
.eqv SYS_Sbrk      9
.eqv SYS_Exit      10
.eqv SYS_PrintChar 11

.text
.global main

main:
	la t1, arr
	li t2, 0
L1:
	li a7, SYS_ReadInt
	ecall
	beqz a0, L2
	sw a0, (t1)
	addi t1, t1, 4
	addi t2, t2, 1
	j L1
L2:
	li a7, SYS_Sbrk
	slli a0, t2, 2
	ecall
	mv s0, a0
	la s1, arr
	mv s2, t2
	
	mv a0, s0
	mv a1, s1
	mv a2, s2
	jal jsort
	mv s0, a0
L3:
	beqz s2, EXIT
	addi s2, s2, -1
	lw a0, (s0)
	addi s0, s0, 4
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
	slli a3, a3, 2
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

# a0: res (int[n])
# a1: arr (int[n])
# a2: n   (int)
# ->  res (int[n])
jsort:
	addi sp, sp, -16
	sw ra, 12(sp)
	li t3, 1
	beq a2, t3, jsort.BASE
	srli a2, a2, 1
	sw a0, 0(sp)
	sw a1, 4(sp)
	sw a2, 8(sp)
	jal jsort
	lw a0, 0(sp)
	lw a1, 4(sp)
	lw a2, 8(sp)
	slli a2, a2, 2
	add a0, a0, a2
	add a1, a1, a2
	srli a2, a2, 2
	jal jsort
	lw a0, 0(sp)
	lw a1, 4(sp)
	lw a2, 8(sp)
	slli a2, a2, 1
jsort.L1:
	beqz a2, jsort.L2
	addi a2, a2, -1
	lw t4, (a0)
	sw t4, (a1)
	addi a0, a0, 4
	addi a1, a1, 4
	j jsort.L1
jsort.L2:
	lw a0, 0(sp)
	lw a1, 4(sp)
	lw a3, 8(sp)
	slli a3, a3, 2
	add a2, a1, a3
	srli a3, a3, 2
	jal join
	j jsort.EXIT
jsort.BASE:
	lw t4, (a1)
	sw t4, (a0)
jsort.EXIT:
	lw ra, 12(sp)
	addi sp, sp, 16
	ret
	
.data
.align 2
arr: