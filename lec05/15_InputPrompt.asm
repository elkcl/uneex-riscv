.eqv SYS_PrintInt    1
.eqv SYS_PrintFloat  2
.eqv SYS_PrintDouble 3
.eqv SYS_PrintString 4
.eqv SYS_ReadInt     5
.eqv SYS_ReadFloat   6
.eqv SYS_ReadDouble  7
.eqv SYS_ReadString  8
.eqv SYS_Sbrk        9
.eqv SYS_Exit        10
.eqv SYS_PrintChar   11
.eqv SYS_ReadChar    12   # broken

.macro input(%prompt, %reg)
.data
msg_in:
	.asciz %prompt
.text
	li a7, SYS_PrintString
	la a0, msg_in
	ecall
	li a7, SYS_ReadInt
	ecall
	mv %reg, a0
.end_macro

.macro print(%prompt, %reg)
.data
msg_out:
	.asciz %prompt
.text
	li a7, SYS_PrintString
	la a0, msg_out
	ecall
	li a7, SYS_PrintInt
	mv a0, %reg
	ecall
	li a7, SYS_PrintChar
	li a0, '\n'
	ecall
.end_macro