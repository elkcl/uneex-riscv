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
	la a0, %str
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
	la a0, %dst
	la a1, %src
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
	strlen strget_buf
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
	jal strcpy_
	
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

.macro strcmp(%s1, %s2)
	la a0, %s0
	la a1, %s1
	jal strcmp_
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
	la a0, %str
	li a1, %chr
	jal strchr_
.end_macro


.globl main
main:
	mv s1, zero
L1:
	strget
	beqz a1, EXIT
	blt a1, s1, L1
	mv s1, a1
	syscall PrintString
	putchar '\n'
	j L1
EXIT:
	exit