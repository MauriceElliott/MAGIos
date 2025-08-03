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
5. **Odin compilation fails**: Verify target is `linux_riscv64`

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
