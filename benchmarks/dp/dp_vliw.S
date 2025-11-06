	.file	"dp_scalar.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_a2p1_c2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	dot_product
	.type	dot_product, @function

# int dot_product(int *a, int *b, int *out, int n)
dot_product:
	or	a4,a3,a4              # a4 = a3 | a4 (likely setting up n or clearing flag)
	beq	a4,zero,.L1           # if (n == 0) return
	slli	a3,a3,2               # a3 = n * 4  (convert element count to bytes)
	addi	a6,a3,-4              # a6 = (n*4) - 4
	srli	t0,a6,2               # t0 = n - 1 (roughly divide by 4)
	addi	t1,t0,1               # t1 = n
	andi	t2,t1,4               # t2 = n mod 8 (handle leftover elements)
	add	a7,a0,a3              # a7 = a0 + n*4 (end address of array a)
	li	a5,0                   # a5 = accumulator = 0

	beq	t2,zero,.L4           # if (n % 4 == 0) skip to main loop
	li	t3,1
	beq	t2,t3,.L17            # handle 1 leftover element
	li	t4,2
	beq	t2,t4,.L18            # handle 2 leftover elements

# Handle 3 leftover elements (if n % 4 == 3)
	lw	a5,0(a0)              # load a[i]
	lw	t5,0(a1)              # load b[i]
	addi	a0,a0,4
	addi	a1,a1,4
	mul	a5,a5,t5              # a5 = a[i] * b[i]
	addi	a2,a2,4
	sw	a5,-4(a2)             # store partial sum? (unusual; not a pure dot product)
.L18:
	c.li x0,3     # Hint (VLIW 3)
	lw	t6,0(a0)              # load a[i+1]
	lw	a4,0(a1)              # load b[i+1]
	addi	a2,a2,4

	c.li x0,3     # Hint (VLIW 3)
	addi	a0,a0,4
	addi	a1,a1,4
	mul	a3,t6,a4              # multiply
	
	add	a5,a5,a3              # accumulate
	sw	a5,-4(a2)             # store
.L17:
	lw	t0,0(a0)
	lw	a6,0(a1)
	addi	a0,a0,4
	addi	a1,a1,4
	mul	t1,t0,a6
	addi	a2,a2,4
	add	a5,a5,t1
	sw	a5,-4(a2)
	beq	a7,a0,.L23            # if at end, return

# Main loop: process 4 elements per iteration
.L4:

	c.li x0,4     # Hint (VLIW 4)
		lw	t2,0(a0)              # load a[i]
		lw	t3,0(a1)              # load b[i]
		addi	a0,a0,16             # advance a pointer by 4 elements
		addi	a1,a1,16             # advance b pointer by 4 elements

	c.li x0,4     # Hint (VLIW 4)
		mul	t4,t2,t3              # multiply a[i]*b[i]
		addi	a2,a2,16             # advance output pointer
		lw	t6,-12(a0)
		lw	a4,-12(a1)

	c.li x0,4     # Hint (VLIW 4)
		add	t5,a5,t4              # accumulate partial sum
		mul	a3,t6,a4
		lw	t1,-8(a0)
		lw	a6,-8(a1)

	c.li x0,4     # Hint (VLIW 4)
		sw	t5,-16(a2)            # store
		mul	a5,t1,a6
		lw	t3,-4(a0)
		lw	t4,-4(a1)


	add	t0,t5,a3

	c.li x0,2     # Hint (VLIW 2)
	sw	t0,-12(a2)
	mul	t5,t3,t4

	add	t2,t0,a5

	sw	t2,-8(a2)

	add	a5,t2,t5

	sw	a5,-4(a2)

	bne	a7,a0,.L4             # loop until all elements processed

.L1:
	ret                       # return (result likely in a5)
.L23:
	ret
	.size	dot_product, .-dot_product
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
