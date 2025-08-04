# MAGIos CPU Assembly Helper Functions

.section .text

# Disable interrupts
.globl cpu_disable_interrupts
cpu_disable_interrupts:
    csrci mstatus, 0x8 # Clear MIE bit (bit 3)
    ret

#enable interrupts
.globl cpu_enable_interrupts
cpu_enable_interrupts:
    csrsi mstatus, 0x8
    ret

.globl cpu_halt
cpu_halt:
    wfi # wait for interrupt
    ret

.globl cpu_halt_forever
cpu_halt_forever:
    csrci mstatus, 0x8
1:
    wfi
    j 1b

.globl cpu_read_mmio_8
cpu_read_mmio_8:
    lb a0, 0(a0)
    ret

.globl cpu_read_mmio_32
cpu_read_mmio_32:
    lw a0, 0(a0)
    ret

.globl cpu_read_mmio_64
cpu_read_mmio_64:
    ld a0, 0(a0)        # Load double-word from address
    ret

# Write to memory-mapped I/O
# Parameters: address in a0, value in a1
.globl cpu_write_mmio_8
cpu_write_mmio_8:
    sb a1, 0(a0)        # Store byte to address
    ret

.globl cpu_write_mmio_32
cpu_write_mmio_32:
    sw a1, 0(a0)        # Store word to address
    ret

.globl cpu_write_mmio_64
cpu_write_mmio_64:
    sd a1, 0(a0)        # Store double-word to address
    ret

# Crash/debug breakpoint equivalent
.globl crash
crash:
    ebreak              # RISC-V debug breakpoint
    j crash             # Loop forever

# Flush instruction cache (RISC-V fence)
.globl cpu_fence_i
cpu_fence_i:
    fence.i             # Instruction fence
    ret

# Memory barrier
.globl cpu_fence
cpu_fence:
    fence               # Memory fence
    ret

.section .note.GNU-stack,"",%progbits
