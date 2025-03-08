.eqv SYS_PrintInt  1
.eqv SYS_ReadInt   5
.eqv SYS_Sbrk      9
.eqv SYS_Exit      10
.eqv SYS_PrintChar 11

.eqv BUF_SIZE 1048576000
.eqv t0_ptr      t0
.eqv t1_sz       t1
.eqv t2_odd      t2
.eqv t3_buf_size t3

.data
	buf: .space BUF_SIZE

.text
.global _start

_start:
	la t0_ptr, buf
	li t1_sz, 0
	li t3_buf_size, BUF_SIZE
L1:
	li a7, SYS_ReadInt
	ecall
	beqz a0, L2
	mv a3, a0
	li a1, 2
	remu a1, a3, a1
	bnez t1_sz, L1_NONSET
	mv t2_odd, a1
L1_NONSET:
	beq t2_odd, a1, L1_SAME
	li a7, SYS_PrintInt
	beqz a1, L1_EVEN
	lw a0, (t0_ptr)
	ecall
	mv a0, a3
	ecall
	j L1_POSTDIFF
L1_EVEN:
	mv a0, a3
	ecall
	lw a0, (t0_ptr)
	ecall
L1_POSTDIFF:
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
	addi t0_ptr, t0_ptr, 4
	remu t0_ptr, t0_ptr, t3_buf_size
	addi t1_sz, t1_sz, -4
	j L1
L1_SAME:
	add a2, t0_ptr, t1_sz
	remu a2, a2, t3_buf_size
	sw a3, (a2)
	addi t1_sz, t1_sz, 4
	j L1
L2:
	beqz t1_sz, EXIT
	li a7, SYS_PrintInt
	lw a0, (t0_ptr)
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
	addi t0_ptr, t0_ptr, 4
	remu t0_ptr, t0_ptr, t3_buf_size
	addi t1_sz, t1_sz, -4
	j L2
EXIT:
	li a7, SYS_Exit
	ecall