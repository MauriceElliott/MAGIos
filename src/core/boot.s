# MAGIos Boot

.section .text.boot
.globl _start

_start:
    # entrypoint for OpenSBI

    # disable interrupts during boot
    # OpenSBI hands off in S-mode, so use S-mode CSRs
    csrw sie, zero
    csrw sip, zero

    # Setup stack pointer
    la sp, _stack_top

    # Clear BSS section with proper loop guard
    la t0, _bss_start
    la t1, _bss_end

    # Skip BSS clearing if start >= end (safety check)
    bgeu t0, t1, bss_cleared

clear_bss:
    beq t0, t1, bss_cleared    # Exit when we reach the end
    sd zero, 0(t0)             # Clear 8 bytes
    addi t0, t0, 8             # Move to next 8-byte boundary
    bltu t0, t1, clear_bss     # Continue if t0 < t1

bss_cleared:

    # Call kernel!
    call kernel_main

    # Halt if kernel_main returns, which, in theory, should not happen.

hang:
    wfi # wait for interrupt
    j hang

.section .note.GNU-stack,"",%progbits
