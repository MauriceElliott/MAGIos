# MAGIos RISC-V Trap Handlers
# Lilith System - Trap Management

.section .text
.align 4

.globl set_trap_vector
set_trap_vector:
    la t0, trap_vector
    csrw mtvec, t0
    ret

.globl enable_timer_interrupts
enable_timer_interrupts:
    # Enable machine timer interrupt in mie
    li t0, (1 << 7)
    csrs mie, t0

    # Enable global interrupts in mstatus
    li t0, (1 << 3)
    csrs mstatus, t0
    ret

.globl get_time
get_time:
    # Read current time from CLINT
    li t0, 0x0200BFF8  # CLINT_MTIME
    ld a0, 0(t0)
    ret

.globl set_timer
set_timer:
    # Set timer compare value
    li t0, 0x02004000  # CLINT_MTIMECMP
    sd a0, 0(t0)
    ret

# Main trap vector - saves context and calls Odin handler
.align 4
trap_vector:
    # Save context to stack (simplified for now)
    addi sp, sp, -256  # Space for TrapFrame

    # Save all registers to TrapFrame on stack
    sd ra, 0(sp)
    sd sp, 8(sp)   # Note: this saves the pre-trap SP
    sd gp, 16(sp)
    sd tp, 24(sp)
    sd t0, 32(sp)
    sd t1, 40(sp)
    sd t2, 48(sp)
    sd s0, 56(sp)
    sd s1, 64(sp)
    sd a0, 72(sp)
    sd a1, 80(sp)
    sd a2, 88(sp)
    sd a3, 96(sp)
    sd a4, 104(sp)
    sd a5, 112(sp)
    sd a6, 120(sp)
    sd a7, 128(sp)
    sd s2, 136(sp)
    sd s3, 144(sp)
    sd s4, 152(sp)
    sd s5, 160(sp)
    sd s6, 168(sp)
    sd s7, 176(sp)
    sd s8, 184(sp)
    sd s9, 192(sp)
    sd s10, 200(sp)
    sd s11, 208(sp)
    sd t3, 216(sp)
    sd t4, 224(sp)
    sd t5, 232(sp)
    sd t6, 240(sp)

    # Save special registers
    csrr t0, mepc
    sd t0, 248(sp)     # pc
    csrr t0, mcause
    sd t0, 256(sp)     # cause
    csrr t0, mtval
    sd t0, 264(sp)     # tval
    csrr t0, mstatus
    sd t0, 272(sp)     # status

    # Call Odin trap handler with frame pointer
    mv a0, sp
    call trap_handler

    # Restore context (reverse order)
    ld t0, 248(sp)
    csrw mepc, t0
    ld t0, 272(sp)
    csrw mstatus, t0

    # Restore general registers
    ld ra, 0(sp)
    ld gp, 16(sp)
    ld tp, 24(sp)
    ld t0, 32(sp)
    ld t1, 40(sp)
    ld t2, 48(sp)
    ld s0, 56(sp)
    ld s1, 64(sp)
    ld a0, 72(sp)
    ld a1, 80(sp)
    ld a2, 88(sp)
    ld a3, 96(sp)
    ld a4, 104(sp)
    ld a5, 112(sp)
    ld a6, 120(sp)
    ld a7, 128(sp)
    ld s2, 136(sp)
    ld s3, 144(sp)
    ld s4, 152(sp)
    ld s5, 160(sp)
    ld s6, 168(sp)
    ld s7, 176(sp)
    ld s8, 184(sp)
    ld s9, 192(sp)
    ld s10, 200(sp)
    ld s11, 208(sp)
    ld t3, 216(sp)
    ld t4, 224(sp)
    ld t5, 232(sp)
    ld t6, 240(sp)

    addi sp, sp, 256   # Restore stack pointer

    mret  # Return from trap

.section .note.GNU-stack,"",%progbits
