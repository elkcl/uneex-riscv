.eqv SYS_PrintInt  1
.eqv SYS_ReadInt   5
.eqv SYS_Exit      10
.eqv SYS_PrintChar 11

.text
.global main

main:
	li a7, SYS_ReadInt
	ecall
	mv s1, a0
L1:
	li a7, SYS_ReadInt
	ecall
	beqz a0, EXIT
	mv a1, s1
	jal digit
	li a7, SYS_PrintInt
	ecall
	li a7, SYS_PrintChar
	li a0, ' '
	ecall
	j L1
EXIT:
	li a7, SYS_PrintInt
	li a0, 0
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
	li a7, SYS_Exit
	ecall
	

# a0: num   (int)
# a1: pos   (int)
# ->  digit (int)
digit:
	li t0, 1
	li t1, 0
	li t2, 10
digit.L1:
	bgtu t0, a0, digit.L2
	mul t0, t0, t2
	addi t1, t1, 1
	j digit.L1
digit.L2:
	bgtu a1, t1, digit.NOTFOUND
	sub t1, t1, a1
digit.L3:
	beqz t1, digit.FOUND
	addi t1, t1, -1
	divu a0, a0, t2
	j digit.L3
digit.FOUND:
	remu a0, a0, t2
	ret
digit.NOTFOUND:
	li a0, -1
	ret
