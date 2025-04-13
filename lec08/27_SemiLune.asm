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
	
# t0: lune_x
# t1: lune_y
# t2: lune_r2
# t3: shadow_x
# t4: shadow_y
# t5: shadow_r2
# a0: x
# a1: y
lune:
	sub a2, a0, t0
	sub a3, a1, t1
	mul a2, a2, a2
	mul a3, a3, a3
	add a2, a2, a3
	sgt a4, a2, t2
	xori a4, a4, 1
	
	sub a2, a0, t3
	sub a3, a1, t4
	mul a2, a2, a2
	mul a3, a3, a3
	add a2, a2, a3
	sgt a5, a2, t5
	
	and a0, a4, a5
	ret

.globl main
main:
	syscall ReadInt
	mv t0, a0
	syscall ReadInt
	mv t1, a0
	syscall ReadInt
	mv t2, a0
	syscall ReadInt
	mv t3, a0
	syscall ReadInt
	mv t4, a0
	syscall ReadInt
	mv t5, a0
	syscall ReadInt
	mv s0, a0
	syscall ReadInt
	mv s1, a0

	mul t2, t2, t2
	mul t5, t5, t5	
	render background, s1
	render lune, s0
	exit
	