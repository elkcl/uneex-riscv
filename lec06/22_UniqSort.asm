.eqv PrintInt    1
.eqv PrintFloat  2
.eqv PrintDouble 3
.eqv PrintString 4
.eqv ReadInt     5
.eqv ReadFloat   6
.eqv ReadDouble  7
.eqv ReadString  8
.eqv Sbrk        9
.eqv Exit        10
.eqv PrintChar   11
.eqv ReadChar    12   # broken


.macro syscall(%num)
	li a7, %num
	ecall
.end_macro

.macro putchar(%chr)
	li a0, %chr
	syscall PrintChar
.end_macro

.macro exit
	syscall Exit
.end_macro

strlen_:
	mv t0, a0
	li a0, 0
strlen_L1:
	lbu t1, (t0)
	beqz t1, strlen_L2
	addi t0, t0, 1
	addi a0, a0, 1
	j strlen_L1
strlen_L2:
	ret

.macro strlen(%str)
	mv a0, %str
	jal strlen_
.end_macro

 
strcpy_:
	mv t0, a1
	mv t1, a0
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
	ret
	
.macro strcpy(%dst, %src)
	mv a0, %dst
	mv a1, %src
	jal strcpy_
.end_macro

.data
strget_buf:
	.space 103
.text
strget_:
	addi sp, sp, -4
	sw ra, (sp)
	
	la a0, strget_buf
	li a1, 101
	syscall ReadString
	strlen a0
	beqz a0, strget_no_endl
	la t0, strget_buf
	add t0, t0, a0
	addi t0, t0, -1
	lbu t1, (t0)
	li t2, '\n'
	bne t1, t2, strget_no_endl
	mv t1, zero
	sb t1, (t0)
	addi a0, a0, -1
strget_no_endl:
	mv t3, a0
	addi a0, a0, 1
	syscall Sbrk
	la a1, strget_buf
	strcpy a0, a1
	
	lw ra, (sp)
	addi sp, sp, 4
	ret
	
.macro strget
	jal strget_
.end_macro


strcmp_:
	lbu t0, (a0)
	lbu t1, (a1)
	bne t0, t1, strcmp_RET
	beqz t0, strcmp_RET
	addi a0, a0, 1
	addi a1, a1, 1
	j strcmp_
strcmp_RET:
	sub a0, t0, t1
	ret

.macro strcmp(%s0, %s1)
	mv a0, %s0
	mv a1, %s1
	jal strcmp_
.end_macro

ispref_:
	lbu t0, (a0)
	lbu t1, (a1)
	beqz t0, ispref_YES
	bne t0, t1, ispref_NO
	addi a0, a0, 1
	addi a1, a1, 1
	j ispref_
ispref_NO:
	sub a0, t0, t1
	ret
ispref_YES:
	mv a0, zero
	ret

.macro ispref(%s0, %s1)
	mv a0, %s0
	mv a1, %s1
	jal ispref_
.end_macro


strchr_:
	lbu t0, (a0)
	beq t0, a1, strchr_FOUND
	beqz t0, strchr_NOTFOUND
	addi a0, a0, 1
	j strchr_
strchr_NOTFOUND:
	mv a0, zero
strchr_FOUND:
	ret

.macro strchr(%str, %chr)
	mv a0, %str
	li a1, %chr
	jal strchr_
.end_macro


.globl main
main:
	syscall ReadInt
	mv s1, a0
	beqz a0, EXIT
	slli a0, a0, 2
	syscall Sbrk
	mv s2, a0
	mv s3, s1
	mv s4, s2
L1:
	beqz s3, L1_END
	addi s3, s3, -1
	strget
	sw a0, (s4)
	mv s5, s4
L2:
	beq s5, s2, L2_END
	lw t0, -4(s5)
	lw t1, 0(s5)
	strcmp t0, t1
	blez a0, L2_END
	lw t0, -4(s5)
	lw t1, 0(s5)
	sw t1, -4(s5)
	sw t0, 0(s5)
	addi s5, s5, -4
	j L2
L2_END:
	addi s4, s4, 4
	j L1
L1_END:
	mv s3, s1
	mv s4, s2
	mv s5, s2
	addi s3, s3, -1
	addi s4, s4, 4
	addi s5, s5, 4
L3:
	beqz s3, L4
	addi s3, s3, -1
	lw t0, -4(s4)
	lw t1, 0(s5)
	strcmp t0, t1
	beqz a0, L3_SKIP
	lw t1, 0(s5)
	sw t1, 0(s4)
	addi s4, s4, 4
L3_SKIP:
	addi s5, s5, 4
	j L3
L4:
	beq s2, s4, EXIT
	lw a0, (s2)
	syscall PrintString
	putchar '\n'
	addi s2, s2, 4
	j L4
EXIT:
	exit