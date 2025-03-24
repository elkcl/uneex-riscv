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

.macro strlen(%str)
	la t0, %str
	li a0, 0
strlen_L1:
	lbu t1, (t0)
	beqz t1, strlen_L2
	addi t0, t0, 1
	addi a0, a0, 1
	j strlen_L1
strlen_L2:
.end_macro

.macro strcpy(%dst, %src)
	la t0, %src
	la t1, %dst
	mv a0, t1
	li a1, 0
strcpy_L1:
	lbu t2, (t0)
	beqz t2, strcpy_L2
	addi t0, t0, 1
	addi t1, t1, 1
	addi a1, a1, 1
	j strcpy_L1
strcpy_L2:
	lbu t2, (t0)
	sb t2, (t1)
	beq t1, a0, strcpy_L3
	addi t0, t0, -1
	addi t1, t1, -1
	j strcpy_L2
strcpy_L3:
.end_macro

.macro strcat(%dst, %src)
	la t0, %src
	la t1, %dst
	mv a0, t1
	mv t3, t0
	li a1, 0
strcat_L1:
	lbu t2, (t1)
	beqz t2, strcat_L2
	addi t1, t1, 1
	addi a1, a1, 1
	j strcat_L1
strcat_L2:
	lbu t2, (t0)
	beqz t2, strcat_L3
	addi t0, t0, 1
	addi t1, t1, 1
	addi a1, a1, 1
	j strcat_L2
strcat_L3:
	lbu t2, (t0)
	sb t2, (t1)
	beq t0, t3, strcat_L4
	addi t0, t0, -1
	addi t1, t1, -1
	j strcat_L3
strcat_L4:
.end_macro