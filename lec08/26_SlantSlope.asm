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

.eqv DISPLAY_BASE 0x10010000
.eqv W            256
.eqv H            128

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

# a0: predicate addr
# t0, t1, .../fa0, fa1, ... — predicate args
# a1: color
render_:
	addi sp, sp, -24
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	
	mv s0, a0
	mv s1, a1
	li s2, DISPLAY_BASE
	li s4, H
	addi s4, s4, -1
render_L1:
	bltz s4, render_L1e
	li s3, 0
render_L2:
	xori s3, s3, W
	beqz s3, render_L2e
	xori s3, s3, W
	mv a0, s3
	mv a1, s4
	jalr s0
	beqz a0, render_L2_SKIP
	sw s1, (s2)
render_L2_SKIP:
	addi s2, s2, 4
	addi s3, s3, 1
	j render_L2
render_L2e:
	addi s4, s4, -1
	j render_L1
render_L1e:

	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	addi sp, sp, 24
	ret

.macro render(%pred, %color)
	la a0, %pred
	mv a1, %color
	jal render_
.end_macro

background:
	li a0, 1
	ret
	
slant:
	fcvt.d.w ft0, a0
	fcvt.d.w ft1, a1
	fcvt.d.w ft2, zero
	fmul.d ft0, ft0, fa0
	fmul.d ft1, ft1, fa1
	fadd.d ft0, ft0, ft1
	fadd.d ft0, ft0, fa2
	fge.d a0, ft0, ft2
	ret

.globl main
main:
	syscall ReadDouble
	fmv.d fs0, fa0
	syscall ReadDouble
	fmv.d fa1, fa0
	syscall ReadDouble
	fmv.d fa2, fa0
	fmv.d fa0, fs0
	syscall ReadInt
	mv s0, a0
	syscall ReadInt
	mv s1, a0
	
	render background, s1
	render slant, s0
	exit
	