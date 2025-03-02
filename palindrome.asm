.eqv SYS_PrintString 4
.eqv SYS_ReadInt     5
.eqv SYS_Exit        10
.eqv highest_mask    0xf0000000
.eqv lowest_mask     0xf

.data
	YES: .asciz "YES"
	NO:  .asciz "NO"

.text
.global _start

_start:
	li a7, SYS_ReadInt
	ecall
	beqz a0, LY
	mv a1, a0
	li a5, highest_mask
L1:
	and a2, a1, a5
	bnez a2, L2
	slli a1, a1, 4
	j L1
L2:
	beqz a0, LY
	and a2, a1, a5
	srli a2, a2, 28
	andi a3, a0, lowest_mask
	bne a2, a3, LN
	slli a1, a1, 4
	srli a0, a0, 4
	j L2
LN:
	li a7, SYS_PrintString
	la a0, NO
	ecall
	j EXIT
LY:
	li a7, SYS_PrintString
	la a0, YES
	ecall
EXIT:
	li a7, SYS_Exit
	ecall