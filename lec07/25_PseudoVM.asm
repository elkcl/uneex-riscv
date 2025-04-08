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
vtable:
	.space 128
.text
handler:
	addi sp, sp, -20
	sw a0, 0(sp)
	sw a1, 4(sp)
	sw t1, 8(sp)
	sw a2, 12(sp)
	sw t2, 16(sp)

	csrr a0, utval
	beqz a0, handler_WRONG
	csrr a0, ucause
	andi a0, a0, 0x1f
	li a1, 5
	beq a0, a1, handler_LOOKUP
	li a1, 7
	beq a0, a1, handler_LOOKUP
handler_WRONG:
	csrci ustatus, 4
	lw a0, 0(sp)
	lw a1, 4(sp)
	lw t1, 8(sp)
	lw a2, 12(sp)
	lw t2, 16(sp)
	addi sp, sp, 20
	uret
handler_LOOKUP:
	csrr a0, utval
	la a1, vtable
	li a2, 16
	li t2, -1
handler_L1:
	beqz a2, handler_NF
	lw t1, (a1)
	beq t1, a0, handler_FOUND
	bnez t1, handler_L1_NZ
	mv t2, a1
handler_L1_NZ:
	addi a1, a1, 8
	addi a2, a2, -1
	j handler_L1
handler_FOUND:
	csrr a0, ucause
	andi a0, a0, 0x1f
	xori a0, a0, 7
	beqz a0, handler_FOUND_STORE
	lw t0, 4(a1)
	j handler_EXIT
handler_FOUND_STORE:
	sw t0, 4(a1)
	j handler_EXIT
handler_NF:
	csrr a0, ucause
	andi a0, a0, 0x1f
	xori a0, a0, 7
	beqz a0, handler_NF_STORE
	li t0, 0
	j handler_EXIT
handler_NF_STORE:
	li a0, -1
	beq t2, a0, handler_EXIT
	csrr a0, utval
	sw a0, 0(t2)
	sw t0, 4(t2)
	j handler_EXIT
handler_EXIT:
	csrr t3, uepc
	addi t3, t3, 4
	csrrw zero, uepc, t3
	mul a0, a0, t2
	li a7, 71
	
	lw a0, 0(sp)
	lw a1, 4(sp)
	lw t1, 8(sp)
	lw a2, 12(sp)
	lw t2, 16(sp)
	addi sp, sp, 20
	uret