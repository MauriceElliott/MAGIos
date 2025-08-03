# MAGIos

A 64-bit RISC-V operating system kernel written in Odin, inspired by the aesthetics and themes of Neon Genesis Evangelion.

![MAGIos](resources/MAGIos.png)

## Overview

MAGIos is experimental. It is a conduit for me to learn how an OS works as well as giving me an outlet for creativity.

I have chosen Odin for this project as out of the choices, it filled me with the least sadness over leaving my beloved swift behind. Although so far its been a glorious choice and will most likely be my chosen language for everything going forward.

The project has migrated from x86 32-bit to RISC-V 64-bit architecture to leverage Odin's superior support for modern architectures and to work with a cleaner, more future-oriented instruction set.

Currently I am making this as a terminal type application, possibly something that could run under WSL on Windows. Eventually I would like to make a GUI library, something that fits the 90s anime theme. But the thing is this isn't just about the aesthetics of the externally facing application, this is also about the codebase, so as you can probably see, the kernel file being called adam, and the interrupt system being called lilith make this less than ideal as a learning device for others. Because of this, I have done my best to leave as many comments with as much details as is possible.

## Features

- **Pure Odin Implementation**: Kernel logic written entirely in Odin with minimal assembly bootstrap
- **RISC-V 64-bit Architecture**: Modern, clean instruction set with excellent Odin support
- **Evangelion Theming**: Designed to mimic the MAGI system as that aspect of Evangelion has always fascinated me
- **UART Serial Output**: Text-based interface through serial console
- **OpenSBI Compatible**: Boots via OpenSBI supervisor binary interface
- **Cross-Platform Build**: Supports macOS and Linux development environments

## Requirements

- Odin compiler (latest version)
- RISC-V 64-bit cross-compiler toolchain
- QEMU RISC-V emulator
- OpenSBI firmware

### Installing Dependencies (macOS)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install QEMU with RISC-V support
brew install qemu

# Install RISC-V cross-compiler
brew tap riscv-software-src/riscv
brew install riscv64-elf-gcc

# Install Odin from https://odin-lang.org/docs/install/
```

### Installing Dependencies (Linux)

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install qemu-system-riscv64 gcc-riscv64-linux-gnu

# Or build from source for bare-metal toolchain
# See: https://github.com/riscv-collab/riscv-gnu-toolchain
```

## Build and Run

```bash
# Run in QEMU with serial console
./build.sh --run

# Run in headless mode (for testing)
./build.sh --test

# Clean build artifacts
./build.sh --clean
```

### Odin Kernel Details

The kernel is compiled with these Odin flags:

- `-target:linux_riscv64` - RISC-V 64-bit target (freestanding)
- `-no-bounds-check` - Disable runtime bounds checking
- `-no-crt` - No C runtime
- `-default-to-nil-allocator` - No default allocator
- `-no-entry-point` - Custom entry from assembly

## Architecture Notes

### RISC-V vs x86 Migration

This project was migrated from x86 32-bit to RISC-V 64-bit for several reasons:

- **Better Odin Support**: RISC-V has cleaner integration with modern languages
- **Simpler Architecture**: No legacy baggage, cleaner instruction set
- **Modern Design**: RISC-V is designed for the future of computing
- **Educational Value**: Learning a modern architecture vs legacy x86

### Key Differences

- **Boot Process**: Uses OpenSBI instead of GRUB multiboot
- **Interrupts**: RISC-V trap handling instead of x86 IDT
- **Output**: UART serial console instead of VGA text mode
- **Addressing**: 64-bit virtual memory instead of 32-bit protected mode

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE Version 3.

## Acknowledgments

- Inspired by Neon Genesis Evangelion by Hideaki Anno
- Built with the Odin programming language by gingerBill
- RISC-V architecture by RISC-V Foundation
- OpenSBI supervisor binary interface

---

"God's in his heaven, all's right with the world." - NERV Motto
"Get in the fucking robot shinji" - Commander Ikari
