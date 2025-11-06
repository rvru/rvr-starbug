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
	or	a4,a3,a4              # a4 = a3 | a4
	beq	a4,zero,.L25          # if (a3 | a4) == 0 goto L25 (early return)
	addi	sp,sp,-32             # allocate 32 bytes stack frame
	sw	s3,16(sp)              # save s3

	c.li x0,2     # Hint (VLIW 2)
	mv	s3,a5                  # s3 = a5
	sw	s1,24(sp)              # save s1

	c.li x0,4     # Hint (VLIW 4)
	sw	s2,20(sp)              # save s2
	sw	s4,12(sp)              # save s4
	slli	a3,a3,2               # a3 = a3 << 2 (multiply by 4)
	or	a4,s3,a6              # a4 = s3 | a6

	c.li x0,4     # Hint (VLIW 4)
	mv	s2,a1                  # s2 = a1
	mv	s1,a6                  # s1 = a6
	mv	a5,a2                  # a5 = a2
	mv	a6,a0                  # a6 = a0

	c.li x0,4     # Hint (VLIW 4)
	add	s4,a2,a3               # s4 = a2 + a3
	li	t6,0                   # t6 = 0
	li	a1,0                   # a1 = 0
	bne	a4,zero,.L31           # if (s3|a6) != 0 goto L31

.L14:                               # loop: clear memory block
	sw	zero,0(a5)             # *a5 = 0
	addi	a5,a5,4               # a5 += 4
	bne	a5,s4,.L14             # repeat until a5 == s4

	c.li x0,4     # Hint (VLIW 6)
	lw	s1,24(sp)              # restore s1
	lw	s2,20(sp)              # restore s2
	lw	s3,16(sp)              # restore s3
	lw	s4,12(sp)              # restore s4
	addi	sp,sp,32              # deallocate stack frame
	jr	ra                     # return

.L31:
	c.li x0,2     # Hint (VLIW 2)
	seqz	t0,s3                 # t0 = (s3 == 0)
	sw	s0,28(sp)              # save s0

	c.li x0,2     # Hint (VLIW 2)
	sub	t0,s1,t0              # t0 = s1 - t0
	addi	s0,s3,-1              # s0 = s3 - 1

.L10:                               # outer loop start
	c.li x0,4     # Hint (VLIW 4)
	mv	t2,s0                  # t2 = s0
	mv	t5,t0                  # t5 = t0
	bgtu	t0,a1,.L6             # if (t0 > a1) goto L6
	beq	t0,a1,.L32            # else if (t0 == a1) goto L32

.L5:
	c.li x0,5     # Hint (VLIW 5)
	mv	a7,s2                  # a7 = s2
	mv	a0,a6                  # a0 = a6
	li	a3,0                   # a3 = 0
	li	a2,0                   # a2 = 0
	li	t4,0                   # t4 = 0

.L21:           # inner loop start (THIS DOMINATES RUN TIME)
	c.li x0,6     # Hint (VLIW 6)
	lw	t3,0(a7)               # t3 = *a7
	lw	a4,0(a0)               # a4 = *a0
	addi	t1,a3,1               # t1 = a3 + 1
	sltu	a3,t1,a3              # a3 = (t1 < a3) ? 1 : 0  (detect overflow)
	addi	a0,a0,-4              # a0 -= 4 (move pointer backwards)
	addi	a7,a7,4               # a7 += 4

	c.li x0,4     # Hint (VLIW 4)
	mul	a4,a4,t3               # a4 = a4 * t3
	add	t3,a3,a2              # t3 = a3 + a2 (accumulate with carry)
	mv	a2,t3                  # a2 = t3
	mv	a3,t1                  # a3 = t1
	
	add	a4,t4,a4               # a4 = t4 + a4

	c.li x0,5     # Hint (VLIW 5)
	mv	t4,a4                  # t4 = a4
	bgtu	t3,t5,.L16            # if (t3 > t5) goto L16
	sw	a4,0(a5)               # *a5 = a4 (THIS INST WAS MOVED FORM L16)
	bne	t3,t5,.L21            # else if (t3 != t5) repeat inner loop
	bleu	t1,t2,.L21            # else if (t1 <= t2) repeat inner loop

.L16:                               # after inner loop
	c.li x0,4     # Hint (VLIW 4)
	addi	a3,t6,1               # a3 = t6 + 1
	sltu	t6,a3,t6              # t6 = (a3 < t6) ? 1 : 0 (detect overflow)
	# sw	a4,0(a5)               # *a5 = a4 MOVED TO L21
	addi	a5,a5,4               # a5 += 4
	add	a1,t6,a1               # a1 = a1 + t6

	c.li x0,3     # Hint (VLIW 3)
	addi	a6,a6,4               # a6 += 4
	mv	t6,a3                  # t6 = a3
	bne	s4,a5,.L10             # if (a5 != s4) repeat outer loop

	c.li x0,7     # Hint (VLIW 7)
	lw	s0,28(sp)              # restore s0
	lw	s1,24(sp)              # restore s1
	lw	s2,20(sp)              # restore s2
	lw	s3,16(sp)              # restore s3
	lw	s4,12(sp)              # restore s4
	addi	sp,sp,32              # deallocate stack
	jr	ra                     # return

.L32:
	bleu	s0,t6,.L5             # if (s0 <= t6) goto L5

.L6:
	c.li x0,3     # Hint (VLIW 3)
	mv	t2,t6                  # t2 = t6
	mv	t5,a1                  # t5 = a1
	j	.L5                    # goto L5

.L25:
	ret                          # return

	.size	fir_filter, .-fir_filter
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
