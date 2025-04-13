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

.macro abs(%dreg, %sreg, %treg)
	li %treg, 31
	sra %treg, %sreg, %treg
	xor %dreg, %treg, %sreg
	sub %dreg, %dreg, %treg
.end_macro

# a0: predicate addr
# t0, t1, .../fa0, fa1, ... — predicate args
# a1: color
# a2: x_min
# a3: x_max
# a4: y_min
# a5: y_max
render_:
	addi sp, sp, -36
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	sw s5, 24(sp)
	sw s6, 28(sp)
	sw s7, 32(sp)
	
	mv s0, a0
	
	bgez a2, render_XMIN_VALID
	li a2, 0
render_XMIN_VALID:
	bgez a4, render_YMIN_VALID
	li a4, 0
render_YMIN_VALID:
	li a0, W
	blt a3, a0, render_XMAX_VALID
	mv a3, a0
	addi a3, a3, -1
render_XMAX_VALID:
	li a0, H
	blt a5, a0, render_YMAX_VALID
	mv a5, a0
	addi a5, a5, -1
render_YMAX_VALID:
	mv s1, a1
	mv s4, a5
	mv s5, a2
	mv s6, a3
	addi s6, s6, 1
	mv s7, a4
render_L1:
	blt s4, s7, render_L1e
	mv s3, s5
	li s2, H
	addi s2, s2, -1
	sub s2, s2, s4
	li a0, W
	mul s2, s2, a0
	add s2, s2, s3
	slli s2, s2, 2
	li a0, DISPLAY_BASE
	add s2, s2, a0
render_L2:
	beq s3, s6, render_L2e
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
	lw s5, 24(sp)
	lw s6, 28(sp)
	lw s7, 32(sp)
	addi sp, sp, 36
	ret

.macro render(%pred, %color)
	mv a1, %color
	la a0, %pred
	li a2, 0
	li a3, W
	addi a3, a3, -1
	li a4, 0
	li a5, H
	addi a5, a5, -1
	jal render_
.end_macro

background:
	li a0, 1
	ret


# t0: square_r
# t1: square_x
# t2: square_y
# a0: x
# a1: y
square:
	sub a2, a0, t1
	sub a3, a1, t2
	abs a2, a2, a4
	abs a3, a3, a4
	add a2, a2, a3
	sgt a0, a2, t0
	xori a0, a0, 1
	ret
	
.globl main
main:
	syscall ReadInt
	render background, a0
L1:
	syscall ReadInt
	beqz a0, EXIT
	mv t0, a0
	syscall ReadInt
	mv t1, a0
	syscall ReadInt
	mv t2, a0
	syscall ReadInt
	mv a1, a0
	la a0, square
	sub a2, t1, t0
	add a3, t1, t0
	sub a4, t2, t0
	add a5, t2, t0
	jal render_
	j L1
EXIT:
	exit
	
