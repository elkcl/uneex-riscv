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
.text
handler:
	addi sp, sp, -8
	sw a0, 0(sp)
	sw a7, 4(sp)
	
	csrr a0, ucause
	andi a0, a0, 0x1f
	li a7, 2
	bne a0, a7, handler_WRONG
	csrr a0, uepc
	lw a0, (a0)
	andi a7, a0, 0x7f
	xori a7, a7, 0x73
	bnez a7, handler_WRONG
	li a7, 0x3000
	and a7, a0, a7
	beqz a7, handler_WRONG
handler_EXIT:
	csrr a0, uepc
	addi a0, a0, 4
	csrrw zero, uepc, a0
	lw a0, 0(sp)
	lw a7, 4(sp)
	addi sp, sp, 8
	uret
handler_WRONG:
	la a0, exception_msg
	syscall PrintString
	csrr a0, ucause
	andi a0, a0, 0x1f
	syscall PrintInt
	putchar '\n'
	exit
