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
	# prologue: allocate stack + save ra,s0, create frame pointer s0 and save args
	# c.li x0,3     # Hint (VLIW 3)
	addi	sp,sp,-80
	sw	ra,76(sp)
	sw	s0,72(sp)

	# c.li x0,3     # Hint (VLIW 3)
	addi	s0,sp,80
	sw	a0,-52(s0)
	sw	a1,-56(s0)

	c.li x0,3     # Hint (VLIW 3)
	sw	a2,-60(s0)
	sw	a3,-72(s0)
	sw	a4,-68(s0)

	c.li x0,4     # Hint (VLIW 4)
	sw	a5,-80(s0)
	sw	a6,-76(s0)
	# initialize counters / temporaries
	li	a5,0
	li	a6,0

	c.li x0,3     # Hint (VLIW 3)
	sw	a5,-24(s0)
	sw	a6,-20(s0)
	j	.L2

.L8:
	# zero four counters in one go
	c.li x0,6     # Hint (VLIW 6)
	li	a5,0
	li	a6,0
	sw	a5,-32(s0)
	sw	a6,-28(s0)
	sw	a5,-40(s0)
	sw	a6,-36(s0)

	j	.L3

.L6:
	# compare lw a4,-36(s0) and lw a5,-20(s0)
	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-36(s0)
	lw	a5,-20(s0)

	bgtu	a4,a5,.L4

	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-36(s0)
	lw	a5,-20(s0)

	bne	a4,a5,.L10

	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-40(s0)
	lw	a5,-24(s0)

	bgtu	a4,a5,.L4

.L10:
	# Compute index differences and load table entries
	# these loads and arithmetic are bundled where dependencies allow
	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-24(s0)        # a4 = idx1
	lw	a5,-40(s0)        # a5 = idx2

	sub	a5,a4,a5         # a5 = a4 - a5
	slli	a5,a5,2         # a5 = byte offset

	# c.li x0,4     # Hint (VLIW 4)
	lw	a4,-52(s0)        # a4 = coeffs_base
	add	a5,a4,a5         # address = base + offset
	lw	a5,0(a5)          # load coeff -> a5
	mv	t1,a5

	srai	a5,a5,31
	mv	t2,a5

	c.li x0,2     # Hint (VLIW 2)
	lw	a5,-40(s0)        # a5 = idx2
	lw	a4,-56(s0)        # a4 = samples_base

	slli	a5,a5,2
	add	a5,a4,a5

	lw	a5,0(a5)
	mv	t3,a5
	srai	a5,a5,31
	mv	t4,a5

	# multiplies and sums (some parallelism possible)
	c.li x0,2   # Hint (VLIW 2)
	mul	a4,t2,t3         # a4 = sign(t1)*t3 ?
	mul	a5,t4,t1

	add	a5,a4,a5

	# c.li x0,4     # Hint (VLIW 4)
	mul	a4,t1,t3
	mulhu	t6,t1,t3
	mv	t5,a4
	add	a5,a5,t6

	mv	t6,a5

	# update circular buffers: add and wrap computations
	# c.li x0,3     # Hint (VLIW 3)
	lw	a2,-32(s0)
	lw	a3,-28(s0)
	add	a4,a2,t5

	# c.li x0,4     # Hint (VLIW 4)
	mv	a1,a4
	sltu	a1,a1,a2
	add	a5,a3,t6
	add	a3,a1,a5

	# c.li x0,3     # Hint (VLIW 3)
	mv	a5,a3
	sw	a4,-32(s0)
	sw	a5,-28(s0)

.L4:
	# increment indexes in another circular buffer region
	# c.li x0,6     # Hint (VLIW 6)
	lw	a2,-40(s0)
	lw	a3,-36(s0)
	li	a0,1
	li	a1,0
	add	a4,a2,a0
	mv	a6,a4

	c.li x0,3     # Hint (VLIW 3)
	sltu	a6,a6,a2
	add	a5,a3,a1
	add	a3,a6,a5

	mv	a5,a3
	sw	a4,-40(s0)
	sw	a5,-36(s0)

.L3:
	# outer comparisons against -76(s0)
	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-76(s0)
	lw	a5,-36(s0)

	bgtu	a4,a5,.L6

	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-76(s0)
	lw	a5,-36(s0)

	bne	a4,a5,.L11

	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-80(s0)
	lw	a5,-40(s0)

	bgtu	a4,a5,.L6

.L11:
	# store sample into output array
	# c.li x0,3     # Hint (VLIW 3)
	lw	a5,-24(s0)
	slli	a5,a5,2
	lw	a4,-60(s0)

	add	a5,a4,a5

	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-32(s0)
	sw	a4,0(a5)

	# advance and wrap the write pointer counters
	c.li x0,6     # Hint (VLIW 6)
	lw	a2,-24(s0)
	lw	a3,-20(s0)
	li	a0,1
	li	a1,0
	add	a4,a2,a0
	mv	a6,a4

	c.li x0,4     # Hint (VLIW 4)
	sltu	a6,a6,a2
	add	a5,a3,a1
	add	a3,a6,a5

	mv	a5,a3

	c.li x0,2     # Hint (VLIW 2)
	sw	a4,-24(s0)
	sw	a5,-20(s0)

.L2:
	# loop test for main outer loop
	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-68(s0)
	lw	a5,-20(s0)

	bgtu	a4,a5,.L8

	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-68(s0)
	lw	a5,-20(s0)

	bne	a4,a5,.L12

	c.li x0,2     # Hint (VLIW 2)
	lw	a4,-72(s0)
	lw	a5,-24(s0)

	bgtu	a4,a5,.L8

.L12:
	nop

	lw	ra,76(sp)
	lw	s0,72(sp)

	addi	sp,sp,80
	jr	ra
	.size	fir_filter, .-fir_filter
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
