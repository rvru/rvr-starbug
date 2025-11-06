	.file	"fir_filter_scalar.c"          # source file name
	.option nopic                      # no position independent code
	.attribute arch, "rv32i2p1_m2p0_a2p1_c2p0" # target arch info
	.attribute unaligned_access, 0     # unaligned access not allowed
	.attribute stack_align, 16         # stack must be 16-byte aligned
	.text
	.align	1
	.globl	fir_filter
	.type	fir_filter, @function
fir_filter:
	or	a5,a3,a4
	beq	a5,zero,.L37
	lw	t0,0(a0)
	lw	a7,0(a1)
	li	a6,1
	mul	t1,t0,a7
	sw	t1,0(a2)
	beq	a3,a6,.L40
.L20:
	addi	sp,sp,-48
	lw	t2,0(a0)
	lw	a4,0(a1)
	sw	s0,44(sp)
	sw	s1,40(sp)
	lw	s0,4(a1)
	lw	s1,4(a0)
	sw	s9,8(sp)
	mul	s9,s0,t2
	slli	a3,a3,2
	sw	s2,36(sp)
	sw	s3,32(sp)
	sw	s4,28(sp)
	sw	s5,24(sp)
	sw	s6,20(sp)
	sw	s7,16(sp)
	sw	s8,12(sp)
	add	t1,a2,a3
	mul	t3,a4,s1
	addi	a6,a2,4
	li	t4,0
	li	a2,1
	li	t5,2
	li	s8,3
	li	s7,4
	li	s6,5
	li	s5,6
	li	s4,7
	li	s3,8
	li	s2,9
	li	s1,10
	li	s0,11
	li	t2,12
	li	t0,13
	li	t6,14
	add	s9,s9,t3
.L5:
	addi	a3,a2,1
	sltu	a2,a3,a2
	add	t3,a2,t4
	sw	s9,0(a6)
	addi	a6,a6,4
	addi	a0,a0,4
	mv	t4,t3
	mv	a2,a3
	beq	a6,t1,.L1
	lw	a5,0(a0)
	lw	s9,4(a0)
	lw	a4,4(a1)
	lw	a7,0(a1)
	mul	a4,a4,a5
	lw	a5,8(a1)
	mul	a7,a7,s9
	lw	s9,-4(a0)
	mul	a5,a5,s9
	add	a4,a4,a7
	add	s9,a5,a4
	beq	a3,t5,.L41
.L19:
	lw	a5,12(a1)
	lw	a7,-8(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s8,.L42
.L21:
	lw	a5,16(a1)
	lw	a7,-12(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s7,.L43
.L22:
	lw	a5,20(a1)
	lw	a7,-16(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s6,.L44
.L23:
	lw	a5,24(a1)
	lw	a7,-20(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s5,.L45
.L24:
	lw	a5,28(a1)
	lw	a7,-24(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s4,.L46
.L25:
	lw	a5,32(a1)
	lw	a7,-28(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s3,.L47
.L26:
	lw	a5,36(a1)
	lw	a7,-32(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s2,.L48
.L27:
	lw	a5,40(a1)
	lw	a7,-36(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s1,.L49
.L28:
	lw	a5,44(a1)
	lw	a7,-40(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,s0,.L50
.L29:
	lw	a5,48(a1)
	lw	a7,-44(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,t2,.L51
.L30:
	lw	a5,52(a1)
	lw	a7,-48(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,t0,.L52
.L31:
	lw	a5,56(a1)
	lw	a7,-52(a0)
	mul	a4,a5,a7
	add	s9,s9,a4
	beq	a3,t6,.L53
.L32:
	lw	t3,60(a1)
	lw	a3,-56(a0)
	mul	a5,t3,a3
	add	s9,s9,a5
	j	.L5
.L1:
	lw	s0,44(sp)
	lw	s1,40(sp)
	lw	s2,36(sp)
	lw	s3,32(sp)
	lw	s4,28(sp)
	lw	s5,24(sp)
	lw	s6,20(sp)
	lw	s7,16(sp)
	lw	s8,12(sp)
	lw	s9,8(sp)
	addi	sp,sp,48
	jr	ra
.L40:
	bne	a4,zero,.L20
.L37:
	ret
.L53:
	bne	t3,zero,.L32
	j	.L5
.L52:
	bne	t3,zero,.L31
	j	.L5
.L51:
	bne	t3,zero,.L30
	j	.L5
.L50:
	bne	t3,zero,.L29
	j	.L5
.L49:
	bne	t3,zero,.L28
	j	.L5
.L48:
	bne	t3,zero,.L27
	j	.L5
.L47:
	bne	t3,zero,.L26
	j	.L5
.L46:
	bne	t3,zero,.L25
	j	.L5
.L45:
	bne	t3,zero,.L24
	j	.L5
.L44:
	bne	t3,zero,.L23
	j	.L5
.L43:
	bne	t3,zero,.L22
	j	.L5
.L42:
	bne	t3,zero,.L21
	j	.L5
.L41:
	bne	t3,zero,.L19
	j	.L5
	.size	fir_filter, .-fir_filter
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
