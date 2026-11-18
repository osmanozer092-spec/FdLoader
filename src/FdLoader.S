.section .text.boot, "ax"
.global _start

.if (FD_SIZE % 8) != 0
.error "FD_SIZE must be a multiple of 8"
.endif

_start:
    adrp x19, _Target
    add  x19, x19, :lo12:_Target

    mrs  x0, sctlr_el1
    bic  x0, x0, #(1 << 1)
    msr  sctlr_el1, x0
    isb

    bl   main

    mov  x4, x19
    movz x5, #0xA000, lsl #16
    mov  x20, x5
    ldr  x6, fd_size
    lsr  x6, x6, #3
1:  cbz  x6, 2f
    ldr  x2, [x4], #8
    str  x2, [x5], #8
    sub  x6, x6, #1
    b    1b
2:  mov  x21, x5

    mov  x4, x20
3:  dc   civac, x4
    add  x4, x4, #64
    cmp  x4, x21
    b.lo 3b

    dsb  sy
    ic   iallu
    dsb  sy
    isb

    br   x20

.balign 8
fd_size:
    .quad FD_SIZE
