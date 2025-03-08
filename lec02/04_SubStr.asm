.eqv SYS_PrintString 4
.eqv SYS_ReadString  8
.eqv SYS_Exit        10
.eqv SYS_PrintChar   11

.eqv t0_str1_base t0
.eqv t1_str1_ptr  t1
.eqv t2_str2_ptr  t2
.eqv t3_endl      t3

.data
	YES: .asciz "YES\n"
	NO:  .asciz "NO\n"
	str1:  .space 501
	str2:  .space 501

.text
.global _start

_start:
	li t3_endl, '\n'
	li a7, SYS_ReadString
	la a0, str1
	li a1, 500
	ecall
	la a0, str2
	ecall
	
	la t0_str1_base, str1
L1:
	mv t1_str1_ptr, t0_str1_base
	la t2_str2_ptr, str2
L2:
	lb a1, (t1_str1_ptr)
	addi t1_str1_ptr, t1_str1_ptr, 1
	lb a2, (t2_str2_ptr)
	addi t2_str2_ptr, t2_str2_ptr, 1
	beq a2, t3_endl, LY
	beqz a2, LY
	beq a1, a2, L2
	addi t0_str1_base, t0_str1_base, 1
	lb a0, (t0_str1_base)
	beq a0, t3_endl, LN
	beqz a0, LN
	j L1
LY:
	li a7, SYS_PrintString
	la a0, YES
	ecall
	j EXIT
LN:
	li a7, SYS_PrintString
	la a0, NO
	ecall
EXIT:
	li a7, SYS_Exit
	ecall