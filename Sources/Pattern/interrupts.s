# MAGIos RISC-V Trap Handlers
# Tabris - Trap Management

.section .text
.align 4

.globl set_trap_vector
set_trap_vector:
    la t0, trap_vector
    csrw stvec, t0
    ret

.globl enable_timer_interrupts
enable_timer_interrupts:
    # Enable supervisor timer interrupt in sie
    li t0, (1 << 5)
    csrs sie, t0

    # Enable global interrupts in sstatus
    li t0, (1 << 1)
    csrs sstatus, t0
    ret

.globl get_time
get_time:
    rdtime a0
    ret

.globl set_timer
set_timer:
    li a7, 0x54494D45 #SBI Timer Extension EID
    li a6, 0
    ecall
    ret

# Main trap vector - saves context and calls Odin handler
.align 4
trap_vector:
    # Save context to stack (simplified for now)
    csrw sscratch, sp     # Temporarily save original SP in sscratch
    addi sp, sp, -288     # Space for TrapFrame (36 registers × 8 bytes)

    # Save all registers to TrapFrame on stack
    sd ra, 0(sp)
    sd t0, 32(sp)         # Save t0 FIRST before it gets clobbered
    csrr t0, sscratch     # Get original SP from sscratch
    sd t0, 8(sp)          # Save the ORIGINAL SP value
    sd gp, 16(sp)
    sd tp, 24(sp)
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
    csrr t0, sepc
    sd t0, 248(sp) # pc
    csrr t0, scause
    sd t0, 256(sp) # cause
    csrr t0, stval
    sd t0, 264(sp) # tval
    csrr t0, sstatus
    sd t0, 272(sp) # status

    # Call trap handler with frame pointer
    mv a0, sp
    call trap_handler

    # Restore context (reverse order)
    ld t0, 248(sp)
    csrw sepc, t0
    ld t0, 272(sp)
    csrw sstatus, t0

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
    
    ld sp, 8(sp)      # Restore original stack pointer from saved value

    sret # Return from trap

.section .note.GNU-stack,"",%progbits
