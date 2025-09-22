# MAGIos Boot
.section .text
.globl _start

_start:

        # disable interupts during boot
        # OpenSBI hands off in S-mode
        csrw sie, zero
        csrw sip, zero

        # Set up stack (assume linker script provides _stack_top)
        la sp, _stack_top

        # Clear BSS section with proper loop guard
        la t0, _bss_start
        la t1, _bss_end

        # Skip BSS clearing if start >= end

        bgeu t0, t1, bss_cleared

clear_bss:
        beq t0, t1, bss_cleared    # Exit when we reach the end
        sd zero, 0(t0)             # Clear 8 bytes
        addi t0, t0, 8             # Move to next 8-byte boundary
        bltu t0, t1, clear_bss     # Continue if t0 < t1

bss_cleared:
        # Jump to Swift kernel entry point
        call kernel_main

hang:
        wfi
        j hang
