# MAGIos Boot

.section .text.boot
.globl _start

_start:
    # entrypoint for OpenSBI

    # disable interrupts during boot
    # CSR is the Control and Status Registry, csrw is writing to it.
    csrw mie, zero
    csrw sie, zero

    # la means load address
    la sp, _stack_top

    # clear bss section.
    la t0, _bss_start
    la t1, _bss_end
clear_bss:
    # not sure honestly. says branch if zero in the docs, but branch to what who knows?
    beq t0, t1, bss_cleared
    # zero's out the t0 address space afaik.
    sd zero, 0(t0)
    addi t0, t0, 8
    j clear_bss # j for jump, or goto
bss_cleared:

    # Call kernel!
    call kernel_main

    # Halt if kernel_main returns, which, in theory, should not happen.

hang:
    wfi # wait for interrupt
    j hang

.section .note.GNU-stack,"",%progbits
