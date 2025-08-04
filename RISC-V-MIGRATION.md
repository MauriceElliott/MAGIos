# MAGIos RISC-V Migration Guide

## Overview

This document outlines the complete migration of MAGIos from x86 32-bit to RISC-V 64-bit architecture. This migration was undertaken to leverage Odin's superior support for modern architectures and to work with a cleaner, more future-oriented instruction set without legacy baggage.

## Architecture Comparison

| Aspect              | x86 32-bit (Before)      | RISC-V 64-bit (After)               |
| ------------------- | ------------------------ | ----------------------------------- |
| **Instruction Set** | CISC, complex legacy     | RISC, clean and simple              |
| **Registers**       | Limited, special-purpose | 32 general-purpose registers        |
| **Boot Process**    | GRUB Multiboot           | OpenSBI Supervisor Binary Interface |
| **Interrupts**      | IDT + PIC programming    | Trap vectors + PLIC/CLINT           |
| **Output**          | VGA text mode (0xB8000)  | UART serial console                 |
| **Memory Model**    | 32-bit protected mode    | 64-bit virtual memory               |
| **Odin Support**    | Problematic linking      | Excellent native support            |

## Migration Steps

### Phase 1: Documentation and Build System Update ✅

1. **Update README.md** - Architecture change, dependencies, build instructions
2. **Update LLM_RULES.md** - Technical constraints and platform requirements
3. **Update build.sh** - RISC-V toolchain, QEMU configuration
4. **Create this migration guide**

### Phase 2: Boot Sequence Migration

#### Current x86 Boot Flow:

```
GRUB → Multiboot Header → boot.s → kernel_main()
```

#### New RISC-V Boot Flow:

```
OpenSBI → Machine Mode → Supervisor Mode → boot.s → kernel_main()
```

**Files to update:**

- `src/core/boot.s` - Complete rewrite for RISC-V assembly
- `src/linker.ld` - Memory layout for RISC-V virtual addressing
- Remove `src/grub.cfg` (no longer needed)

### Phase 3: Assembly Code Migration

#### Register Mapping:

| x86 32-bit                 | RISC-V 64-bit | Purpose                   |
| -------------------------- | ------------- | ------------------------- |
| `eax`, `ebx`, `ecx`, `edx` | `a0-a7`       | Function arguments/return |
| `esp`                      | `sp` (x2)     | Stack pointer             |
| `ebp`                      | `fp` (x8)     | Frame pointer             |
| -                          | `ra` (x1)     | Return address            |

#### Key Assembly Changes:

- **Function calls**: `call` → `jal`
- **Returns**: `ret` → `jalr zero, ra, 0`
- **Stack operations**: `push`/`pop` → `addi sp, sp, -8` + `sd`/`ld`
- **Memory access**: `mov [addr], reg` → `sd reg, offset(base)`

### Phase 4: Interrupt System Migration

#### x86 Interrupt System (Old):

```odin
IDTEntry :: struct {
    offset_low:  u16,
    selector:    u16,
    zero:        u8,
    type_attr:   u8,
    offset_high: u16,
}
```

#### RISC-V Trap System (New):

```odin
TrapFrame :: struct {
    registers: [32]u64,  // x0-x31
    pc:        u64,      // Program counter
    cause:     u64,      // Trap cause
    tval:      u64,      // Trap value
}
```

**Key Changes:**

- Replace IDT with trap vector table
- Replace PIC programming with PLIC/CLINT setup
- Interrupt handlers use different calling convention

### Phase 5: Output System Migration

#### From VGA Text Mode:

```odin
// x86 VGA memory-mapped I/O
vga_buffer := cast(^u16)0xB8000
vga_buffer[pos] = u16(char) | (u16(color) << 8)
```

#### To UART Serial Console:

```odin
// RISC-V UART memory-mapped I/O
UART_BASE :: 0x10000000
uart_write_char :: proc(char: u8) {
    uart := cast(^volatile u8)UART_BASE
    uart^ = char
}
```

### Phase 6: Memory Management Migration

#### x86 Protected Mode (Old):

- 32-bit linear addressing
- Segmentation + paging
- GDT setup required

#### RISC-V Virtual Memory (New):

- 64-bit virtual addressing
- Page-based virtual memory (Sv39/Sv48)
- Simplified address translation

## Toolchain Requirements

### macOS Installation:

```bash
# Install QEMU with RISC-V support
brew install qemu

# Install RISC-V cross-compiler
brew tap riscv-software-src/riscv
brew install riscv64-elf-gcc

# Verify installation
qemu-system-riscv64 --version
riscv64-elf-gcc --version
```

### Linux Installation:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install qemu-system-riscv64 gcc-riscv64-linux-gnu

# Or build from source for bare-metal toolchain
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv64gc --with-abi=lp64d
make
```

## QEMU Configuration

### New QEMU Command:

```bash
qemu-system-riscv64 \
    -machine virt \           # Virtual RISC-V machine
    -cpu rv64 \              # RISC-V 64-bit CPU
    -smp 1 \                 # Single CPU core
    -m 128M \                # 128MB RAM
    -nographic \             # No graphics, serial only
    -serial stdio \          # Serial console to terminal
    -bios default \          # Use built-in OpenSBI
    -kernel kernel.elf       # Load our kernel directly
```

### Memory Map (QEMU virt machine):

```
0x00000000 - Boot ROM
0x02000000 - CLINT (Core Local Interruptor)
0x0C000000 - PLIC (Platform Level Interrupt Controller)
0x10000000 - UART
0x80000000 - RAM start
```

## Expected Benefits

1. **Better Odin Integration**: Native RISC-V support eliminates linking issues
2. **Cleaner Architecture**: No x86 legacy baggage, simpler instruction set
3. **Modern Design**: RISC-V is designed for the future of computing
4. **Educational Value**: Learning modern architecture principles
5. **Simplified Interrupt Handling**: Cleaner trap model vs complex IDT
6. **64-bit Addressing**: Larger address space for future expansion

## Implementation Order

1. **Boot Assembly** (`boot.s`) - Get basic kernel loading working
2. **UART Output** (`adam.odin`) - Enable console output for debugging
3. **Trap Handling** (`lilith.odin`) - Basic exception handling
4. **Timer Interrupts** - Get periodic interrupts working
5. **Input Handling** - UART-based keyboard input
6. **Memory Management** - Virtual memory setup
7. **Advanced Features** - Build on stable foundation

## Detailed Implementation Guide

### Phase 1: RISC-V Boot Assembly (`src/core/boot.s`)

**Goal**: Get the kernel to boot and call `kernel_main()` successfully.

**Create new `src/core/boot.s`:**

```assembly
# MAGIos RISC-V Boot Assembly
# Terminal Dogma Boot Sequence - RISC-V Edition

.section .text.boot
.globl _start

_start:
    # MAGI System Boot Initialization
    # RISC-V 64-bit entry point from OpenSBI

    # Disable interrupts during boot
    csrw mie, zero
    csrw sie, zero

    # Set up stack pointer (use symbol from linker script)
    la sp, _stack_top

    # Clear BSS section (MELCHIOR system initialization)
    la t0, _bss_start
    la t1, _bss_end
clear_bss:
    beq t0, t1, bss_cleared
    sd zero, 0(t0)
    addi t0, t0, 8
    j clear_bss
bss_cleared:

    # Call main kernel function (preserve Evangelion theming)
    call kernel_main

    # Halt if kernel_main returns (should never happen)
hang:
    wfi  # Wait for interrupt (power saving)
    j hang

.section .note.GNU-stack,"",%progbits
```

**Testing Phase 1:**

```bash
./build.sh --test
```

**Expected Output:**

- Build should succeed
- QEMU should boot but likely hang (no output yet)
- No crash or error messages

---

### Phase 2: UART Output System (`src/core/adam.odin`)

**Goal**: Replace VGA text mode with UART serial console for Evangelion-themed output.

**Key changes to `src/core/adam.odin`:**

1. **Replace VGA constants with UART:**

```odin
// Replace this block:
VGA_WIDTH :: 80
VGA_HEIGHT :: 25
VGA_MEMORY :: 0xB8000

// With UART constants:
UART_BASE :: 0x10000000
UART_THR :: 0  // Transmit Holding Register offset
UART_LSR :: 5  // Line Status Register offset
```

2. **Replace VGA color system:**

```odin
// Remove VGA color constants, replace with ANSI escape codes
ANSI_RESET :: "\x1b[0m"
ANSI_BLACK :: "\x1b[30m"
ANSI_RED :: "\x1b[31m"
ANSI_GREEN :: "\x1b[32m"
ANSI_YELLOW :: "\x1b[33m"
ANSI_BLUE :: "\x1b[34m"
ANSI_MAGENTA :: "\x1b[35m"
ANSI_CYAN :: "\x1b[36m"
ANSI_WHITE :: "\x1b[37m"
```

3. **Replace terminal output functions:**

```odin
// Replace VGA memory access with UART
uart_write_char :: proc(char: u8) {
    uart_base := cast(^volatile u8)UART_BASE
    // Wait for transmit ready
    for {
        lsr := cast(^volatile u8)(UART_BASE + UART_LSR)
        if (lsr^ & 0x20) != 0 do break  // THR empty
    }
    // Send character
    thr := cast(^volatile u8)(UART_BASE + UART_THR)
    thr^ = char
}

terminal_putchar :: proc(char: u8) {
    uart_write_char(char)
}

// Update terminal_clear to use ANSI escape sequences
terminal_clear :: proc() {
    terminal_write("\x1b[2J\x1b[H")  // Clear screen + home cursor
}

// Update color functions
terminal_setcolor :: proc(color: string) {
    terminal_write(color)
}
```

4. **Update boot sequence colors:**

```odin
boot_sequence :: proc() {
    terminal_clear()

    // MAGI System header with ANSI colors
    terminal_setcolor(ANSI_CYAN)
    terminal_write("MAGIos RISC-V Boot Sequence Initiated.\n")
    terminal_write("--------------------------------------\n\n")

    // MAGI subsystems status
    terminal_setcolor(ANSI_GREEN)
    terminal_write("CASPER-1 Online... (RISC-V RV64GC)\n")
    terminal_write("MELCHIOR-2 Online... (Virtual Memory)\n")
    terminal_write("BALTHASAR-3 Online... (Trap System)\n\n")

    // Final status
    terminal_setcolor(ANSI_RED)
    terminal_write("MAGI System nominal.\n")
    terminal_write("God is in his heaven, all is right with the world.\n")

    terminal_setcolor(ANSI_RESET)
}
```

**Testing Phase 2:**

```bash
./build.sh --run
```

**Expected Output:**

```
MAGIos RISC-V Boot Sequence Initiated.
--------------------------------------

CASPER-1 Online... (RISC-V RV64GC)
MELCHIOR-2 Online... (Virtual Memory)
BALTHASAR-3 Online... (Trap System)

MAGI System nominal.
God is in his heaven, all is right with the world.
```

---

### Phase 2.5: RISC-V CPU Helper Functions (`src/core/cpu.s`)

**Goal**: Replace x86 CPU helper functions with RISC-V equivalents for interrupt control and system management.

**Remove old `src/core/cpu.s` and create new RISC-V version:**

```assembly
# MAGIos RISC-V CPU Assembly Helper Functions
# Provides RISC-V instruction wrappers for Odin kernel

.section .text

# Disable machine-level interrupts
.globl cpu_disable_interrupts
cpu_disable_interrupts:
    csrci mstatus, 0x8  # Clear MIE bit (bit 3)
    ret

# Enable machine-level interrupts
.globl cpu_enable_interrupts
cpu_enable_interrupts:
    csrsi mstatus, 0x8  # Set MIE bit (bit 3)
    ret

# Halt CPU (wait for interrupt)
.globl cpu_halt
cpu_halt:
    wfi  # Wait for interrupt
    ret

# Halt CPU forever (infinite loop)
.globl cpu_halt_forever
cpu_halt_forever:
    csrci mstatus, 0x8  # Disable interrupts first
1:
    wfi                 # Wait for interrupt
    j 1b                # Jump back

# Read from memory-mapped I/O (RISC-V doesn't have port I/O)
# Parameter: address in a0, returns value in a0
.globl cpu_read_mmio_8
cpu_read_mmio_8:
    lb a0, 0(a0)        # Load byte from address
    ret

.globl cpu_read_mmio_32
cpu_read_mmio_32:
    lw a0, 0(a0)        # Load word from address
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
```

**Update `src/core/adam.odin` to use new RISC-V functions:**

Replace x86 port I/O references:

```odin
// Remove these foreign declarations:
// cpu_inb :: proc(port: u16) -> u8 ---
// cpu_outb :: proc(port: u16, value: u8) ---

// Add these RISC-V foreign declarations:
foreign _ {
    cpu_disable_interrupts :: proc() ---
    cpu_enable_interrupts :: proc() ---
    cpu_halt :: proc() ---
    cpu_halt_forever :: proc() ---
    cpu_read_mmio_8 :: proc(addr: uintptr) -> u8 ---
    cpu_write_mmio_8 :: proc(addr: uintptr, value: u8) ---
    cpu_read_mmio_32 :: proc(addr: uintptr) -> u32 ---
    cpu_write_mmio_32 :: proc(addr: uintptr, value: u32) ---
    cpu_read_mmio_64 :: proc(addr: uintptr) -> u64 ---
    cpu_write_mmio_64 :: proc(addr: uintptr, value: u64) ---
    crash :: proc() ---
    cpu_fence :: proc() ---
    cpu_fence_i :: proc() ---
}
```

**Update UART functions to use memory-mapped I/O:**

```odin
uart_write_char :: proc(char: u8) {
    // Wait for transmit ready using memory-mapped I/O
    lsr_addr := UART_BASE + UART_LSR
    for {
        lsr := cpu_read_mmio_8(lsr_addr)
        if (lsr & 0x20) != 0 do break  // THR empty
    }
    // Send character
    thr_addr := UART_BASE + UART_THR
    cpu_write_mmio_8(thr_addr, char)
}
```

**Testing Phase 2.5:**

```bash
./build.sh --test
```

**Expected Output:**

- Build should succeed with new RISC-V CPU functions
- UART output should still work correctly
- Interrupt enable/disable functions ready for Phase 3

**Key Differences from x86:**

- **No Port I/O**: RISC-V uses memory-mapped I/O instead of `in`/`out` instructions
- **CSR Instructions**: Control and Status Register instructions replace x86 flags
- **WFI vs HLT**: `wfi` (Wait For Interrupt) is RISC-V equivalent of x86 `hlt`
- **Memory Barriers**: RISC-V has explicit `fence` instructions for memory ordering

---

### Phase 3: RISC-V Trap System (`src/core/lilith.odin`)

**Goal**: Replace x86 IDT with RISC-V trap handling for exceptions and interrupts.

**Key changes to `src/core/lilith.odin`:**

1. **Replace IDT structures with RISC-V trap frame:**

```odin
// Remove IDTEntry, IDT_PTR, IDT structs
// Add RISC-V trap frame:

TrapFrame :: struct {
    // General-purpose registers x1-x31 (x0 is always 0)
    ra:   u64,  // x1 - Return address
    sp:   u64,  // x2 - Stack pointer
    gp:   u64,  // x3 - Global pointer
    tp:   u64,  // x4 - Thread pointer
    t0:   u64,  // x5 - Temporary
    t1:   u64,  // x6 - Temporary
    t2:   u64,  // x7 - Temporary
    s0:   u64,  // x8 - Saved register / Frame pointer
    s1:   u64,  // x9 - Saved register
    a0:   u64,  // x10 - Function argument / return value
    a1:   u64,  // x11 - Function argument / return value
    a2:   u64,  // x12 - Function argument
    a3:   u64,  // x13 - Function argument
    a4:   u64,  // x14 - Function argument
    a5:   u64,  // x15 - Function argument
    a6:   u64,  // x16 - Function argument
    a7:   u64,  // x17 - Function argument
    s2:   u64,  // x18 - Saved register
    s3:   u64,  // x19 - Saved register
    s4:   u64,  // x20 - Saved register
    s5:   u64,  // x21 - Saved register
    s6:   u64,  // x22 - Saved register
    s7:   u64,  // x23 - Saved register
    s8:   u64,  // x24 - Saved register
    s9:   u64,  // x25 - Saved register
    s10:  u64,  // x26 - Saved register
    s11:  u64,  // x27 - Saved register
    t3:   u64,  // x28 - Temporary
    t4:   u64,  // x29 - Temporary
    t5:   u64,  // x30 - Temporary
    t6:   u64,  // x31 - Temporary

    // Special registers
    pc:     u64,  // Program counter (mepc)
    cause:  u64,  // Trap cause (mcause)
    tval:   u64,  // Trap value (mtval)
    status: u64,  // Status register (mstatus)
}

// Timer interrupt setup
CLINT_BASE :: 0x02000000
CLINT_MTIME :: CLINT_BASE + 0xBFF8
CLINT_MTIMECMP :: CLINT_BASE + 0x4000
```

2. **Replace setup_idt with setup_traps:**

```odin
setup_traps :: proc() {
    terminal_write("Setting up RISC-V trap system...\n")

    // Set trap vector (mtvec) to our trap handler
    // Will be implemented in interrupts.s
    set_trap_vector()

    // Enable timer interrupts
    enable_timer_interrupts()

    terminal_write("RISC-V Trap System Initialized.\n")
}

// These will be implemented as foreign functions
foreign _ {
    set_trap_vector :: proc() ---
    enable_timer_interrupts :: proc() ---
    get_time :: proc() -> u64 ---
    set_timer :: proc(time: u64) ---
}
```

3. **Replace interrupt dispatcher:**

```odin
@(export)
trap_handler :: proc "c" (frame: ^TrapFrame) {
    context = runtime.default_context()

    cause := frame.cause

    // Check if it's an interrupt (MSB set) or exception
    if (cause & (1 << 63)) != 0 {
        // Interrupt
        interrupt_cause := cause & 0x7FFFFFFFFFFFFFFF
        switch interrupt_cause {
        case 7: // Timer interrupt
            handle_timer_interrupt()
        case:
            terminal_write("Unknown interrupt: ")
            terminal_write(eliquence.stringify(interrupt_cause))
            terminal_write("\n")
        }
    } else {
        // Exception
        terminal_write("Exception occurred: ")
        terminal_write(eliquence.stringify(cause))
        terminal_write(" at PC: ")
        terminal_write(eliquence.stringify(frame.pc))
        terminal_write("\n")
        // Halt on exceptions for now
        for {}
    }
}

handle_timer_interrupt :: proc() {
    // Set next timer interrupt (10ms from now)
    current_time := get_time()
    next_time := current_time + 100000  // 10ms at 10MHz
    set_timer(next_time)

    // Optional: show timer tick
    terminal_write("Timer tick\n")
}
```

**Create new `src/core/interrupts.s` for RISC-V:**

```assembly
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
```

**Update `src/core/kernel.odin`:**

```odin
// Replace setup_idt() call with:
setup_traps()
```

**Testing Phase 3:**

```bash
./build.sh --run
```

**Expected Output:**

```
MAGIos RISC-V Boot Sequence Initiated.
--------------------------------------

CASPER-1 Online... (RISC-V RV64GC)
MELCHIOR-2 Online... (Virtual Memory)
BALTHASAR-3 Online... (Trap System)

MAGI System nominal.
God is in his heaven, all is right with the world.

Setting up RISC-V trap system...
RISC-V Trap System Initialized.
Timer tick
Timer tick
Timer tick
...
```

---

### Testing Points and Troubleshooting

**Common Issues:**

1. **Phase 1 - Boot hangs**: Check stack pointer setup in linker script
2. **Phase 2 - No output**: Verify UART base address (0x10000000 for QEMU virt)
3. **Phase 3 - Trap crashes**: Check trap frame size and register saving/restoring

**Debug Commands:**

```bash
# Check if kernel loads correctly
file build/kernel.elf
riscv64-elf-objdump -h build/kernel.elf

# Debug boot process
qemu-system-riscv64 -machine virt -kernel build/kernel.elf -d cpu,int -nographic

# Check assembly output
riscv64-elf-objdump -d build/boot.o
```

**Success Criteria:**

- ✅ Phase 1: Kernel boots without crashing
- ✅ Phase 2: Evangelion boot messages appear via UART
- ✅ Phase 3: Timer interrupts work without system crash

After Phase 3, you'll have a fully functional RISC-V kernel with working output and interrupt handling - a major milestone! 🎌

## Testing Strategy

Each phase should be tested incrementally:

```bash
# Test build system
./build.sh --clean && ./build.sh --test

# Test boot sequence
./build.sh --run
# Should see: "MAGI System Initialization" via UART

# Test output system
# Should see: Evangelion-themed boot messages

# Test interrupt system
# Should handle timer interrupts without crashing

# Test input system
# Should respond to UART input
```

## Resources and Documentation

### RISC-V Specifications:

- [RISC-V ISA Manual](https://riscv.org/technical/specifications/)
- [RISC-V Privileged Architecture](https://github.com/riscv/riscv-isa-manual)
- [OpenSBI Documentation](https://github.com/riscv-software-src/opensbi)

### QEMU RISC-V:

- [QEMU RISC-V Documentation](https://www.qemu.org/docs/master/system/target-riscv.html)
- [QEMU virt Machine](https://www.qemu.org/docs/master/system/riscv/virt.html)

### Odin RISC-V Support:

- [Odin Targets](https://github.com/odin-lang/Odin/tree/master/core/sys)
- [Odin Cross-compilation](https://odin-lang.org/docs/overview/#cross-compilation)

### Assembly Programming:

- [RISC-V Assembly Programmer's Manual](https://github.com/riscv-non-isa/riscv-asm-manual)
- [RISC-V Calling Convention](https://riscv.org/wp-content/uploads/2019/08/riscv-calling-convention.pdf)

## Troubleshooting

### Common Issues:

1. **Toolchain not found**: Ensure riscv64-elf-gcc is in PATH
2. **QEMU crashes**: Check kernel ELF format with `file kernel.elf`
3. **No output**: Verify UART base address (0x10000000 for virt machine)
4. **Boot hangs**: Check linker script memory layout
5. **Odin compilation fails**: Verify target is `freestanding_riscv64`

### Debug Commands:

```bash
# Check ELF file
file build/kernel.elf
riscv64-elf-objdump -h build/kernel.elf

# Debug QEMU
qemu-system-riscv64 -d cpu,int,exec -machine virt -kernel build/kernel.elf

# Check assembly output
riscv64-elf-objdump -d build/boot.o
```

---

_AT Field operational. Pattern Blue. RISC-V synchronization rate holding steady._

**MAGIos Terminal Dogma - RISC-V Ready for Deployment** 🎌
