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

.eqv SEG_LO 0xFFFF0010
.eqv SEG_HI 0xFFFF0011

.text

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

.macro abs(%dreg, %sreg, %treg)
	li %treg, 31
	sra %treg, %sreg, %treg
	xor %dreg, %treg, %sreg
	sub %dreg, %dreg, %treg
.end_macro

.data
outnum_lookup:
	.byte 0x3f, 0x06, 0x5b, 0x4f,
	      0x66, 0x6d, 0x7d, 0x07,
	      0x7f, 0x6f, 0x77, 0x7c,
	      0x39, 0x5e, 0x79, 0x71
.text
outnum:
	li t0, 0xff
	li t1, SEG_LO
	li t2, SEG_HI
	la t3, outnum_lookup
	bgtu a0, t0, outnum_OF
	andi t0, a0, 0xf
	add t0, t0, t3
	lbu t0, (t0)
	sb t0, (t1)
	andi t0, a0, 0xf0
	srli t0, t0, 4
	beqz t0, outnum_Z
	add t0, t0, t3
	lbu t0, (t0)
	sb t0, (t2)
	ret
outnum_Z:
	li t0, 0
	sb t0, (t2)
	ret
outnum_OF:
	li t0, 0x80
	sb t0, (t1)
	sb t0, (t2)
	ret