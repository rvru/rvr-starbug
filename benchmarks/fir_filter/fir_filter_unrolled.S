	.file	"fir_filter_scalar.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.globl	fir_filter
	.type	fir_filter, @function
fir_filter:
	or	a5,a3,a4
	beq	a5,zero,.L34
	lw	t0,0(a0)
	lw	a7,0(a1)
	addi	sp,sp,-48
	sw	s0,44(sp)
	mul	t1,a7,t0
	sw	s1,40(sp)
	sw	s2,36(sp)
	sw	s3,32(sp)
	sw	s4,28(sp)
	sw	s5,24(sp)
	sw	s6,20(sp)
	sw	s7,16(sp)
	sw	s8,12(sp)
	li	a6,1
	mv	t5,a6
	addi	t3,a2,4
	addi	a5,a0,4
	li	t6,2
	li	t4,3
	li	t0,4
	li	t2,5
	li	s0,6
	li	s1,7
	li	s2,8
	sw	t1,0(a2)
	li	s3,9
	li	s4,10
	li	s5,11
	li	s6,12
	li	s7,14
.L4:
	beq	a3,a6,.L38
.L26:
	lw	s8,0(a1)
	lw	a7,0(a5)
	lw	t1,4(a1)
	mul	a7,a7,s8
	lw	s8,-4(a5)
	mul	t1,t1,s8
	add	a7,a7,t1
	beq	a6,t5,.L39
	lw	t1,8(a1)
	lw	s8,-8(a5)
	mul	t1,t1,s8
	add	a7,t1,a7
	beq	a6,t6,.L40
	lw	t1,12(a1)
	lw	s8,-12(a5)
	mul	t1,t1,s8
	add	t1,t1,a7
	beq	a6,t4,.L41
	lw	a7,16(a1)
	lw	s8,-16(a5)
	mul	a7,a7,s8
	add	a7,a7,t1
	beq	a6,t0,.L42
	lw	t1,20(a1)
	lw	s8,-20(a5)
	mul	t1,t1,s8
	add	t1,t1,a7
	beq	a6,t2,.L43
	lw	a7,24(a1)
	lw	s8,-24(a5)
	mul	a7,a7,s8
	add	a7,a7,t1
	beq	a6,s0,.L44
	lw	t1,28(a1)
	lw	s8,-28(a5)
	mul	t1,t1,s8
	add	t1,t1,a7
	beq	a6,s1,.L45
	lw	a7,32(a1)
	lw	s8,-32(a5)
	mul	a7,a7,s8
	add	a7,a7,t1
	beq	a6,s2,.L46
	lw	t1,36(a1)
	lw	s8,-36(a5)
	mul	t1,t1,s8
	add	a7,t1,a7
	beq	a6,s3,.L47
	lw	t1,40(a1)
	lw	s8,-40(a5)
	mul	t1,t1,s8
	add	t1,t1,a7
	beq	a6,s4,.L48
	lw	a7,44(a1)
	lw	s8,-44(a5)
	mul	a7,a7,s8
	add	a7,a7,t1
	beq	a6,s5,.L49
	lw	t1,48(a1)
	lw	s8,-48(a5)
	mul	t1,t1,s8
	add	a7,t1,a7
	beq	a6,s6,.L50
	lw	t1,52(a1)
	lw	s8,-52(a5)
	mul	t1,t1,s8
	add	a7,t1,a7
	bne	a6,s7,.L51
	lw	a5,-56(a5)
	lw	a6,56(a1)
	mul	t0,a5,a6
	add	t2,t0,a7
	sw	t2,0(t3)
	beq	a4,zero,.L52
.L19:
	slli	a3,a3,2
	add	s4,a2,a3
	addi	t4,a2,60
.L24:
	lw	t3,60(a0)
	lw	a2,56(a0)
	lw	s0,0(a1)
	lw	s5,4(a1)
	lw	s6,52(a0)
	lw	s3,8(a1)
	lw	s7,48(a0)
	lw	a3,12(a1)
	mul	t5,t3,s0
	lw	s2,44(a0)
	lw	s8,16(a1)
	lw	s1,40(a0)
	lw	t0,20(a1)
	lw	s0,36(a0)
	lw	t6,32(a0)
	lw	t3,28(a0)
	lw	t1,24(a0)
	lw	a7,20(a0)
	mul	a5,a2,s5
	lw	a6,16(a0)
	lw	a2,12(a0)
	addi	t4,t4,4
	addi	a0,a0,4
	mul	t2,s6,s3
	add	a4,t5,a5
	lw	a5,-4(a0)
	mul	s5,s7,a3
	add	s6,t2,a4
	lw	a4,24(a1)
	lw	s7,4(a0)
	lw	t2,56(a1)
	mul	s3,s2,s8
	add	t5,s5,s6
	lw	s5,28(a1)
	lw	s8,0(a0)
	mul	s1,s1,t0
	add	s2,s3,t5
	lw	s3,32(a1)
	lw	t0,60(a1)
	mul	s0,s0,a4
	add	a3,s1,s2
	lw	s1,36(a1)
	lw	a4,40(a1)
	mul	t6,t6,s5
	add	s6,s0,a3
	lw	s0,44(a1)
	mul	t3,t3,s3
	add	t5,t6,s6
	lw	t6,48(a1)
	lw	s3,52(a1)
	mul	t1,t1,s1
	add	s2,t3,t5
	mul	a7,a7,a4
	add	a3,t1,s2
	mul	a6,a6,s0
	add	s5,a7,a3
	mul	a2,a2,t6
	add	s6,a6,s5
	mul	s7,s7,s3
	add	t3,a2,s6
	mul	s8,s8,t2
	add	t2,s7,t3
	mul	a5,a5,t0
	add	t0,s8,t2
	add	t5,a5,t0
	sw	t5,-4(t4)
	bne	s4,t4,.L24
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
	addi	sp,sp,48
	jr	ra
.L39:
	sw	a7,0(t3)
	li	a6,2
	addi	a5,a5,4
	addi	t3,t3,4
	bne	a3,a6,.L26
.L38:
	bne	a4,zero,.L26
	j	.L1
.L40:
	sw	a7,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,3
	j	.L4
.L41:
	sw	t1,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,4
	j	.L4
.L42:
	sw	a7,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,5
	j	.L4
.L43:
	sw	t1,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,6
	j	.L4
.L44:
	sw	a7,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,7
	j	.L4
.L45:
	sw	t1,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,8
	j	.L4
.L46:
	sw	a7,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,9
	j	.L4
.L47:
	sw	a7,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,10
	j	.L4
.L48:
	sw	t1,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,11
	j	.L4
.L49:
	sw	a7,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,12
	j	.L4
.L50:
	sw	a7,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,13
	j	.L4
.L51:
	sw	a7,0(t3)
	addi	a5,a5,4
	addi	t3,t3,4
	li	a6,14
	j	.L4
.L34:
	ret
.L52:
	li	a4,15
	bgtu	a3,a4,.L19
	j	.L1
	.size	fir_filter, .-fir_filter
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
