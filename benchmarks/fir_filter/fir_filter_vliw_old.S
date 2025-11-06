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
	
	addi	sp,sp,-80

	sw	ra,76(sp)

	sw	s0,72(sp)

	addi	s0,sp,80

	sw	a0,-52(s0)

	sw	a1,-56(s0)

	# c.li x0,3     # Hint (VLIW 3)
	sw	a2,-60(s0)
	sw	a3,-72(s0)
	sw	a4,-68(s0)

	# c.li x0,4     # Hint (VLIW 4)
	sw	a5,-80(s0)
	sw	a6,-76(s0)
	# initialize counters / temporaries
	li	a5,0
	li	a6,0

	# c.li x0,3     # Hint (VLIW 3)
	sw	a5,-24(s0)
	sw	a6,-20(s0)
	j	.L2

.L8:
	# zero four counters in one go
	# c.li x0,3     # Hint (VLIW 3)
	li	a5,0
	li	a6,0
	sw	a5,-32(s0)

	# c.li x0,3     # Hint (VLIW 3)
	sw	a6,-28(s0)
	sw	a5,-40(s0)
	sw	a6,-36(s0)

	j	.L3

.L6:
	# compare lw a4,-36(s0) and lw a5,-20(s0)
	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-36(s0)
	lw	a5,-20(s0)

	bgtu	a4,a5,.L4

	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-36(s0)
	lw	a5,-20(s0)

	bne	a4,a5,.L10

	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-40(s0)
	lw	a5,-24(s0)

	bgtu	a4,a5,.L4
.L10: # Compute index differences and load table entries # these loads and arithmetic are bundled where dependencies allow c.li x0,2 # Hint (VLIW 2) lw a4,-24(s0) # a4 = idx1 lw a5,-40(s0) # a5 = idx2 sub a5,a4,a5 # a5 = a4 - a5 slli a5,a5,2 # a5 = byte offset lw a4,-52(s0) # a4 = coeffs_base add a5,a4,a5 # address = base + offset lw a5,0(a5) # load coeff -> a5 mv t1,a5 srai a5,a5,31 mv t2,a5 c.li x0,2 # Hint (VLIW 2) lw a5,-40(s0) # a5 = idx2 lw a4,-56(s0) # a4 = samples_base slli a5,a5,2 add a5,a4,a5 lw a5,0(a5) mv t3,a5 srai a5,a5,31 mv t4,a5 # multiplies and sums (some parallelism possible) c.li x0,2 # Hint (VLIW 2) mul a4,t2,t3 # a4 = sign(t1)*t3 ? mul a5,t4,t1 add a5,a4,a5 c.li x0,3 # Hint (VLIW 3) mul a4,t1,t3 mulhu t6,t1,t3 mv t5,a4 add a5,a5,t6 mv t6,a5 # update circular buffers: add and wrap computations c.li x0,2 # Hint (VLIW 2) lw a2,-32(s0) lw a3,-28(s0) add a4,a2,t5 mv a1,a4 sltu a1,a1,a2 c.li x0,2 # Hint (VLIW 2) add a5,a3,t6 add a3,a1,a5 mv a5,a3 c.li x0,2 # Hint (VLIW 2) sw a4,-32(s0) sw a5,-28(s0)
.L100:
    # Packet 1: preload everything we need (6-wide)
    # c.li x0,4
    lw   t0, -24(s0)     # t0 = idx1
    lw   t3, -40(s0)     # t3 = idx2 (will be reused as sample idx)
    lw   a4, -52(s0)     # a4 = coeffs_base
    lw   a5, -56(s0)     # a5 = samples_base


    # Packet 2: compute index differences / shifts
    # c.li x0,4
    lw   a2, -32(s0)     # a2 = acc_low  (or circ_ptr0 in your previous naming)
    lw   a3, -28(s0)     # a3 = acc_high (or circ_ptr1)
    sub  a0, t0, t3      # a0 = idx1 - idx2
    slli a1, t3, 2       # a1 = idx2 << 2 (sample offset)

    # Packet 3: coeff offset scale
    slli a0, a0, 2       # coeff offset = (idx1 - idx2) << 2

    # Packet 4: form addresses
    # c.li x0,2
    add  a0, a4, a0      # coeff address
    add  a1, a5, a1      # sample address

    # Packet 5: load coeff and sample
    # c.li x0,2
    lw   t1, 0(a0)       # t1 = coeff
    lw   t3, 0(a1)       # t3 = sample

    # Packet 6: signed multiply (64-bit product split)
    # c.li x0,2
    mul   t5, t1, t3     # low  32 bits of product
    mulh  t6, t1, t3     # high 32 bits (signed)

    # Packet 7: 64-bit accumulate into a3:a2 (acc_high:acc_low)
    #    new_low  = acc_low + prod_lo
    #    carry    = (new_low < acc_low) [unsigned]
    #    acc_high = acc_high + prod_hi + carry
    # c.li x0,3
    add   t4, a2, t5     # t4 = new_low
    sltu  t0, t4, a2     # t0 = carry (1 if overflow)
    add   a3, a3, t6     # acc_high += prod_hi
    add   a3, a3, t0     # acc_high += carry
    mv    a2, t4         # acc_low = new_low

    # Packet 8: arithmetic shift-right-by-1 of signed 64-bit acc (fix /2)
    # c.li x0,3
    srai  x30, x13, 1      # t7 = a3 >> 1 (arith), using raw regs
    srli  t0, a2, 1        # t0 = a2 >> 1 (logical)
    slli  t1, a3, 31       # t1 = (a3 bit0) << 31

    # Packet 9: combine shifted parts and write back
    # c.li x0,3
    or    a2, t0, t1       # a2 = new_low
    addi  a3, x30, 0       # a3 = new_high (instead of mv)
    sw    a2, -32(s0)
    sw    a3, -28(s0)

.L4:
	# increment indexes in another circular buffer region
	# c.li x0,2     # Hint (VLIW 2)
	lw	a2,-40(s0)
	lw	a3,-36(s0)

	li	a0,1
	
	li	a1,0

	mv	a6,a4

	add	a4,a2,a0

	# c.li x0,3     # Hint (VLIW 3)
	sltu	a6,a6,a2
	add	a5,a3,a1
	add	a3,a6,a5

	mv	a5,a3

	sw	a4,-40(s0)
	
	sw	a5,-36(s0)

.L3:
	# outer comparisons against -76(s0)
	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-76(s0)
	lw	a5,-36(s0)

	bgtu	a4,a5,.L6

	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-76(s0)
	lw	a5,-36(s0)

	bne	a4,a5,.L11

	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-80(s0)
	lw	a5,-40(s0)

	bgtu	a4,a5,.L6

.L11:
	# store sample into output array
	# # c.li x0,3     # Hint (VLIW 3)
	lw	a5,-24(s0)
	slli	a5,a5,2
	lw	a4,-60(s0)

	add	a5,a4,a5

	# c.li x0,4     # Hint (VLIW 2)
	lw	a4,-32(s0)
	sw	a4,0(a5)
	li	a0,1
	li	a1,0

	# advance and wrap the write pointer counters
	# c.li x0,4     # Hint (VLIW 6)
	lw	a2,-24(s0)
	lw	a3,-20(s0)
	add	a4,a2,a0
	mv	a6,a4

	# c.li x0,4     # Hint (VLIW 4)
	sltu	a6,a6,a2
	add	a5,a3,a1
	add	a3,a6,a5
	mv	a5,a3

	# c.li x0,2     # Hint (VLIW 2)
	sw	a4,-24(s0)
	sw	a5,-20(s0)

.L2:
	# loop test for main outer loop
	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-68(s0)
	lw	a5,-20(s0)

	bgtu	a4,a5,.L8

	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-68(s0)
	lw	a5,-20(s0)

	bne	a4,a5,.L12

	# c.li x0,2     # Hint (VLIW 2)
	lw	a4,-72(s0)
	lw	a5,-24(s0)

	bgtu	a4,a5,.L8

.L12:
	nop

	# c.li x0,3     # Hint (VLIW 3)
	lw	ra,76(sp)
	lw	s0,72(sp)
	addi	sp,sp,80

	jr	ra
	.size	fir_filter, .-fir_filter
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
