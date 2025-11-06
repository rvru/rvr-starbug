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
	# Function entry point.
	# a0: const int *x (input signal)
	# a1: const int *h (filter coefficients)
	# a2: int *y (output signal)
	# a3: int N (number of outputs to compute)
	# a5:a6: long long M (number of coefficients)
	
	or	a4,a3,a4      # Combine N and the low part of M to check if any work needs to be done.
	beq	a4,zero,.L_Early_Exit  # If N=0 and M=0, jump to the end and return.
	
	# --- Function Prologue ---
	addi	sp,sp,-16     # Allocate 16 bytes on the stack for saving registers.
	sw	s0,12(sp)     # Save the callee-saved register s0 onto the stack.

	# --- Setup ---
	# c.li x0,3     # Hint (VLIW 4)
	slli	a3,a3,2       # a3 = N * 4. Calculate the total byte size of the output array.
	or	a4,a5,a6      # Check if M (in a6:a5) is zero. The result goes into a4.
	mv	s0,a1         # s0 = h. Save the base pointer of the coefficient array `h`.
	

	# c.li x0,2     # Hint (VLIW 2)
	add	a1,a2,a3      # a1 = y + (N * 4). Calculate the end address of the output array `y`.
	beq	a4,zero,.L_M0   # If M is 0, jump to a special loop that just writes zeros to the output.
	
	li	t2,0          # t2 = 0. Initialize the low 32 bits of the outer loop counter `n`.
	li	t5,0          # t5 = 0. Initialize the high 32 bits of the outer loop counter `n`.

.L_Outer:                  # == Outer Loop (for n in 0..N-1) ==
	c.li x0,5     # Hint (VLIW 5)
	# This loop calculates one output sample y[n] per iteration.
	mv	t3,s0         # t3 = h. Reset the coefficient pointer to the start of `h`.
	mv	t1,a0         # t1 = &x[n]. Set the input pointer for the current convolution.
	li	a4,0          # a4 = 0. Reset the low 32 bits of the inner loop counter `k`.
	li	a3,0          # a3 = 0. Reset the high 32 bits of the inner loop counter `k`.
	li	t6,0          # t6 = 0. Reset the accumulator for the sum y[n].

.L_Inner:                 # == Inner Loop (for k in 0..M-1) ==
	# This loop computes the sum: h[0]*x[n] + h[1]*x[n-1] + ...
	c.li x0,5     # Hint (VLIW 5)
	addi	a7,a4,1       # a7 = k_low + 1. Pre-calculate for counter update.
	sltu	t4,a7,a4      # Check for 32-bit unsigned overflow in 'k_low'. t4 gets the carry bit.
	# This block handles the boundary condition for x[n-k].
	# It checks if k > n. If so, it skips the multiply-accumulate,
	# effectively treating x[n-k] where n-k < 0 as zero.
	bgtu	a3,t5,.L_Inner_Counter     # if (k_high > n_high) skip MAC.
	bne	a3,t5,.L_MAC    # if (k_high != n_high) continue to MAC.
	bgtu	a4,t2,.L_Inner_Counter     # if (k_low > n_low) skip MAC.

.L_MAC:                 # --- Multiply-Accumulate (MAC) Operation ---
	c.li x0,2     # Hint (VLIW 2)
	lw	a4,0(t1)      # a4 = *t1. Load input sample x[n-k].
	lw	t0,0(t3)      # t0 = *t3. Load coefficient h[k].

	mul	a4,a4,t0      # a4 = x[n-k] * h[k].

	add	t6,t6,a4      # accumulator += a4. Add the product to the sum.

.L_Inner_Counter:                  # --- Inner Loop Counter and Pointer Update ---
	c.li x0,4     # Hint (VLIW 4)
	addi	t1,t1,-4      # t1--. Decrement input pointer to get x[n-(k+1)].
	addi	t3,t3,4       # t3++. Increment coefficient pointer to get h[k+1].
	mv	a4,a7         # k_low = k_low + 1. Update counter 'k' (low part).
	add	a3,t4,a3      # k_high += carry. Update counter 'k' (high part).

	c.li x0,2     # Hint (VLIW 2)
	bne	a5,a7,.L_Inner    # Loop if M_low != k+1. `a5` holds the low part of M.
	bne	a6,a3,.L_Inner    # Loop if M_high != k_high. `a6` holds the high part of M.
	
	# --- Outer Loop Counter and Pointer Update ---
	addi	a4,t2,1       # a4 = n_low + 1.

	c.li x0,3     # Hint (VLIW 3)
	sltu	t2,a4,t2      # Check for 32-bit unsigned overflow in 'n_low'. t2 gets the carry bit.
	sw	t6,0(a2)      # *(y) = accumulator. Store the final sum into the output array.
	addi	a2,a2,4       # y++. Advance the output pointer.

	c.li x0,4     # Hint (VLIW 4)
	add	t5,t2,t5      # n_high += carry. Update counter 'n' (high part).
	addi	a0,a0,4       # x++. Advance the base input pointer for the next iteration (n+1).
	mv	t2,a4         # n_low = n_low + 1. Update counter 'n' (low part).
	bne	a2,a1,.L_Outer     # Loop back to .L_Outer if the output pointer hasn't reached the end.

.L_Epilogue:                  # --- Function Epilogue ---
	lw	s0,12(sp)     # Restore the original value of s0 from the stack.
	addi	sp,sp,16      # Deallocate the stack frame.
	jr	ra            # Return to the calling function.

.L_M0:                  # == Special Case Handler (for M=0) ==
	# This loop fills the output array with zeros since a filter with no
	# coefficients has an output of zero.
	sw	zero,0(a2)    # *(y) = 0.
	addi	a2,a2,4       # y++.
	beq	a2,a1,.L_Epilogue     # If we are done, jump to the epilogue.
	# Loop unrolling: process a second element before checking the condition again.
	sw	zero,0(a2)    # *(y) = 0.
	addi	a2,a2,4       # y++.
	bne	a2,a1,.L_M0     # Loop until the output pointer reaches the end.
	j	.L_Epilogue           # Jump to the epilogue.

.L_Early_Exit:                 # --- Early Exit Path ---
	ret                   # Return immediately (used if N=0 and M=0).

	.size	fir_filter, .-fir_filter
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits