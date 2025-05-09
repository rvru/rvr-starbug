    .section .text
    .global fir_filter
    .align  2

fir_filter:
    # Early return if lengths are 0
    or      a4, a4, a3
    beqz    a4, ret

    # Prologue
    addi    sp, sp, -16
    sw      s0, 12(sp)
    slli    a3, a3, 2
    or      a4, a5, a6

    mv      s0, a1
    add     a1, a2, a3
    beqz    a4, zero_fill

outer_loop:
    li      t2, 0
    li      t5, 0
    mv      t3, s0
    mv      t1, a0

    li      a4, 0
    li      a3, 0
    li      t6, 0

inner_loop:
    lw      a5, 0(t1)
    lw      t0, 0(t3)
    addi    a7, a4, 1
    sltu    t4, a7, a4

    mul     a5, a5, t0
    add     t6, t6, a5
    addi    t1, t1, -4
    addi    t3, t3, 4

    mv      a4, a7
    add     a3, a3, t4
    bne     a5, a7, inner_loop
    bne     a6, a3, inner_loop

    addi    a4, t2, 1
    sltu    t2, a4, t2
    sw      t6, 0(a2)
    addi    a2, a2, 4

    add     t5, t5, t2
    addi    a0, a0, 4
    mv      t2, a4
    bne     a2, a1, outer_loop

epilogue:
    lw      s0, 12(sp)
    addi    sp, sp, 16
    ret

zero_fill:
    sw      zero, 0(a2)
    addi    a2, a2, 4
    beq     a2, a1, epilogue

fill_loop:
    sw      zero, 0(a2)
    addi    a2, a2, 4
    bne     a2, a1, fill_loop

ret:
    ret
