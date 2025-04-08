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

.data
exception_msg:
	.asciz "Exception "
input:
	.space 258
.text
handler:
	addi sp, sp, -16
	sw t0, 0(sp)
	sw t1, 4(sp)
	sw t2, 8(sp)
	sw t3, 12(sp)

	csrr a0, ucause
	andi a0, a0, 0x1f
	xori a0, a0, 8
	bnez a0, handler_WRONG
	xori a7, a7, 71
	bnez a7, handler_WRONG
	la a0, input
	li a1, 256
	syscall ReadString
	la t0, input
	li t2, 1
	li a1, 0
	li a0, 0
handler_L1:
	lbu t1, (t0)
	xori t1, t1, ' '
	bnez t1, handler_L2
	addi t0, t0, 1
	j handler_L1
handler_L2:
	lbu t1, (t0)
	xori t1, t1, '-'
	bnez t1, handler_L3
	addi t2, t2, -2
	addi t0, t0, 1
handler_L3:
	lbu t1, (t0)
	xori t1, t1, '0'
	bnez t1, handler_L4
	addi t0, t0, 1
	addi a1, a1, 1
	j handler_L3
handler_L4:
	li t3, 9
	bgeu a1, t3, handler_EXIT
	lbu t1, (t0)
	li t3, '0'
	bltu t1, t3, handler_EXIT
	li t3, '9'
	bgtu t1, t3, handler_EXIT
	addi t1, t1, -48
	li t3, 10
	mul a0, a0, t3
	add a0, a0, t1
	addi a1, a1, 1
	addi t0, t0, 1
	j handler_L4
handler_EXIT:
	csrr t3, uepc
	addi t3, t3, 4
	csrrw zero, uepc, t3
	mul a0, a0, t2
	li a7, 71
	lw t0, 0(sp)
	lw t1, 4(sp)
	lw t2, 8(sp)
	lw t3, 12(sp)
	addi sp, sp, 16
	uret
handler_WRONG:
	la a0, exception_msg
	syscall PrintString
	csrr a0, ucause
	andi a0, a0, 0x1f
	syscall PrintInt
	putchar '\n'
	exit
