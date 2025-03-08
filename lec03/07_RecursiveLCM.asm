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
	ecall
	mv s2, a0
	mv a0, s1
	mv a1, s2
	jal nod
	divu s1, s1, a0
	mul a0, s1, s2
	li a7, SYS_PrintInt
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
EXIT:
	li a7, SYS_Exit
	ecall
	

# a0: a   (int)
# a1: b   (int)
# ->  gcd (int)
nod:
	beqz a1, nod.BASE
	remu a0, a0, a1
	mv a2, a0
	mv a0, a1
	mv a1, a2
	j nod
nod.BASE:
	ret
