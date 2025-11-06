	.file	"dp_vliw_better.c"
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
	or	a4,a3,a4              # a4 = a3 | a4  (compiler side-effect; ensures 'a4' set)
	beq	a4,zero,.L1           # if (n == 0) return

# Convert element count to bytes
	slli	a3,a3,2               # a3 = n * 4 (size in bytes)
	addi	a7,a3,-4              # a7 = n*4 - 4
	srli	t0,a7,2               # t0 = n - 1
	addi	t1,t0,1               # t1 = n
	andi	t2,t1,15              # t2 = n mod 16  → leftover elements before main loop

# Setup pointers
	add	t4,a0,a3              # t4 = end address of array a
	mv	a5,a0                 # a5 = ptrA (current)
	mv	a3,a1                 # a3 = ptrB (current)
	mv	a4,a2                 # a4 = ptrOut (current)
	li	a6,0                  # a6 = accumulator (sum)

# Handle remainder elements (n % 16)
	beq	t2,zero,.L4           # if divisible by 16, skip to main loop
	li	t3,1
	beq	t2,t3,.L53
	li	t5,2
	beq	t2,t5,.L54
	li	t6,3
	beq	t2,t6,.L55
	li	a7,4
	beq	t2,a7,.L56
	li	t0,5
	beq	t2,t0,.L57
	li	t1,6
	beq	t2,t1,.L58
	li	t3,7
	beq	t2,t3,.L59
	li	t5,8
	beq	t2,t5,.L60
	li	t6,9
	beq	t2,t6,.L61
	li	a7,10
	beq	t2,a7,.L62
	li	t0,11
	beq	t2,t0,.L63
	li	t1,12
	beq	t2,t1,.L64
	li	t3,13
	beq	t2,t3,.L65
	li	t5,14
	beq	t2,t5,.L66

# --- Handle remainder cases (same structure repeated) ---
# Each one loads a[i], b[i], multiplies, accumulates, stores, advances pointers

	lw	a4,0(a1)
	lw	a6,0(a0)
	addi	a5,a0,4
	addi	a3,a1,4
	mul	a6,a6,a4
	addi	a4,a2,4
	sw	a6,0(a2)
.L66:
	lw	a2,0(a5)
	lw	a1,0(a3)
	addi	a5,a5,4
	addi	a3,a3,4
	mul	a0,a2,a1
	addi	a4,a4,4
	add	a6,a6,a0
	sw	a6,-4(a4)
.L65:
    lw      t2,0(a5)
    lw      t6,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     a7,t2,t6
    addi    a4,a4,4
    add     a6,a6,a7
    sw      a6,-4(a4)
.L64:
    lw      t0,0(a5)
    lw      t1,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     t3,t0,t1
    addi    a4,a4,4
    add     a6,a6,t3
    sw      a6,-4(a4)
.L63:
    lw      t5,0(a5)
    lw      a2,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     a1,t5,a2
    addi    a4,a4,4
    add     a6,a6,a1
    sw      a6,-4(a4)
.L62:
    lw      a0,0(a5)
    lw      t2,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     t6,a0,t2
    addi    a4,a4,4
    add     a6,a6,t6
    sw      a6,-4(a4)
.L61:
    lw      a7,0(a5)
    lw      t0,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     t1,a7,t0
    addi    a4,a4,4
    add     a6,a6,t1
    sw      a6,-4(a4)
.L60:
    lw      t3,0(a5)
    lw      t5,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     a2,t3,t5
    addi    a4,a4,4
    add     a6,a6,a2
    sw      a6,-4(a4)
.L59:
    lw      a0,0(a5)
    lw      a1,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     t2,a0,a1
    addi    a4,a4,4
    add     a6,a6,t2
    sw      a6,-4(a4)
.L58:
    lw      t6,0(a5)
    lw      a7,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     t0,t6,a7
    addi    a4,a4,4
    add     a6,a6,t0
    sw      a6,-4(a4)
.L57:
    lw      t1,0(a5)
    lw      t3,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     t5,t1,t3
    addi    a4,a4,4
    add     a6,a6,t5
    sw      a6,-4(a4)
.L56:
    lw      a2,0(a5)
    lw      a0,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     a1,a2,a0
    addi    a4,a4,4
    add     a6,a6,a1
    sw      a6,-4(a4)
.L55:
    lw      t2,0(a5)
    lw      t6,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     a7,t2,t6
    addi    a4,a4,4
    add     a6,a6,a7
    sw      a6,-4(a4)
.L54:
    lw      t0,0(a5)
    lw      t1,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     t3,t0,t1
    addi    a4,a4,4
    add     a6,a6,t3
    sw      a6,-4(a4)
.L53:
    lw      t5,0(a5)
    lw      a2,0(a3)
    addi    a5,a5,4
    addi    a3,a3,4
    mul     a0,t5,a2
    addi    a4,a4,4
    add     a6,a6,a0
    sw      a6,-4(a4)
    beq     t4,a5,.L71

# After cleaning up the leftover elements:
	beq	t4,a5,.L71           # if finished, skip main loop

# --- Main loop: process 16 elements per iteration ---
.L4:
	c.li x0,4     # Hint (VLIW 4)
		lw	t2,0(a5)
		lw	a1,0(a3)
		addi	a5,a5,64           
		addi	a3,a3,64 

	mul	t6,t2,a1

	c.li x0,4     # Hint (VLIW 4)
		addi	a4,a4,64         
		lw	t0,-60(a5)
		lw	t1,-60(a3)
		add	a7,a6,t6    

	c.li x0,2     # Hint (VLIW 2)
		mul	t3,t0,t1
		sw	a7,-64(a4)      

	c.li x0,3     # Hint (VLIW 3)
		lw	a2,-56(a5)
		lw	a0,-56(a3)
		add	t5,a7,t3

	c.li x0,2     # Hint (VLIW 2)
		mul	a6,a2,a0
		sw	t5,-60(a4)

	c.li x0,3     # Hint (VLIW 3)
		lw	a1,-52(a5)
		lw	t6,-52(a3)
		add	t2,t5,a6

	c.li x0,2     # Hint (VLIW 2)
		mul	a7,a1,t6
		sw	t2,-56(a4)

	c.li x0,3     # Hint (VLIW 3)
		lw	t1,-48(a5)
		lw	t3,-48(a3)
		add	t0,t2,a7

	c.li x0,2     # Hint (VLIW 2)
		mul	t5,t1,t3
		sw	t0,-52(a4)

	c.li x0,3     # Hint (VLIW 3)
		add	a2,t0,t5
		lw	a6,-44(a5)
		lw	a0,-44(a3)

	c.li x0,2     # Hint (VLIW 2)
		mul	t2,a6,a0
		sw	a2,-48(a4)

	c.li x0,3     # Hint (VLIW 3)
		add	t6,a2,t2
		lw	a1,-40(a5)
		lw	a7,-40(a3)

	c.li x0,2     # Hint (VLIW 2)
		sw	t6,-44(a4)
		mul	t0,a1,a7

	c.li x0,3     # Hint (VLIW 3)
		add	t1,t6,t0
		lw	t3,-36(a5)
		lw	t5,-36(a3)

	c.li x0,2     # Hint (VLIW 2)
		mul	a2,t3,t5
		sw	t1,-40(a4)

	c.li x0,3     # Hint (VLIW 3)
		add	a6,t1,a2
		lw	t2,-32(a5)
		lw	a0,-32(a3)

	c.li x0,2     # Hint (VLIW 2)
		mul	t6,t2,a0
		sw	a6,-36(a4)

	c.li x0,3     # Hint (VLIW 3)
		add	a7,a6,t6
		lw	a1,-28(a5)
		lw	t0,-28(a3)

	c.li x0,4     # Hint (VLIW 4) NEED TO CHANGE IF 2 LSU
		mul	t1,a1,t0
		lw	t5,-24(a5)
		lw	a2,-24(a3)
		sw	a7,-32(a4)

	c.li x0,4     # Hint (VLIW 4)
		lw	t6,-20(a5)
		lw	a0,-20(a3)
		mul	a6,t5,a2
		add	t3,a7,t1

	c.li x0,2     # Hint (VLIW 2)
		mul	a7,t6,a0
		add	t2,t3,a6

	c.li x0,4     # Hint (VLIW 4) NEED TO CHANGE IF 2 LSU
		sw	t3,-28(a4)
		lw	a1,-16(a5)
		lw	t1,-16(a3)
		add	t0,t2,a7

	c.li x0,3     # Hint (VLIW 3)
		mul	t3,a1,t1
		sw	t0,-20(a4)
		sw	t2,-24(a4)

	c.li x0,3     # Hint (VLIW 3)
		lw	a6,-12(a3)
		lw	a2,-12(a5)
		add	t5,t0,t3

	c.li x0,2     # Hint (VLIW 2)
		mul	t2,a2,a6
		sw	t5,-16(a4)

	c.li x0,3     # Hint (VLIW 3)
		lw	a7,-8(a5)
		lw	a0,-8(a3)
		add	t6,t5,t2

	c.li x0,4     # Hint (VLIW 4) NEED TO CHANGE IF 2 LSU
		sw	t6,-12(a4)
		lw	t3,-4(a5)
		lw	a1,-4(a3)
		mul	t0,a7,a0

	c.li x0,2     # Hint (VLIW 2)
		mul	t5,t3,a1
		add	t1,t6,t0

	c.li x0,2     # Hint (VLIW 2)
		add	a6,t1,t5
		sw	t1,-8(a4)

	sw	a6,-4(a4)

	bne	t4,a5,.L4            # repeat until end of array

.L1:
	ret
.L71:
	ret
	.size	dot_product, .-dot_product
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
