# MAGIos - NERV Operating System

A 32-bit operating system kernel written in Odin, inspired by the aesthetics and themes of Neon Genesis Evangelion.

## Overview

MAGIos is an experimental art piece that explores operating system development through the lens of 1990s anime aesthetics. Built with the Odin programming language, it features a minimal kernel that boots with Evangelion-themed messages referencing the MAGI supercomputer system.

## Features

- **Pure Odin Implementation**: Kernel logic written entirely in Odin with minimal assembly bootstrap
- **Evangelion Theming**: Boot sequences reference MAGI system (CASPER, MELCHIOR, BALTHASAR)
- **VGA Text Mode**: Classic 80x25 character display with 16 colors
- **Multiboot Compliant**: Boots via GRUB bootloader
- **Cross-Platform Build**: Supports macOS and Linux development environments

## Requirements

- Odin compiler (latest version)
- i686-elf cross-compiler toolchain
- NASM assembler
- QEMU emulator
- GRUB tools (grub-mkrescue)

### Installing Dependencies (macOS)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install nasm qemu

# Install cross-compiler
brew tap nativeos/i686-elf-toolchain
brew install i686-elf-toolchain

# Install Odin from https://odin-lang.org/docs/install/
```

## Building

```bash
# Build the kernel and create bootable ISO
./build.sh

# Clean build artifacts
./build.sh --clean
```

## Running

```bash
# Run in QEMU with GUI
./build.sh --run

# Run in headless mode (for testing)
./build.sh --test
```

## Project Structure

```
MAGIos/
├── src/
│   ├── boot.s          # Multiboot header and assembly bootstrap
│   ├── kernel.odin     # Main kernel implementation
│   ├── linker.ld       # Linker script for memory layout
│   └── grub.cfg        # GRUB bootloader configuration
├── build.sh            # Build script with MAGI theming
├── README.md           # This file
├── LICENSE             # MIT License
└── LLM_RULES.md       # Guidelines for LLM interactions
```

## Architecture

The kernel follows a simple architecture:

1. **Boot Sequence**: Assembly bootstrap sets up stack and calls Odin kernel
2. **VGA Driver**: Direct memory-mapped I/O to VGA text buffer at 0xB8000
3. **MAGI Display**: Evangelion-themed boot messages and status display
4. **Halt Loop**: Kernel enters infinite halt after initialization

## Development

### Building from Source

The build process uses a custom build script that:

1. Compiles assembly bootstrap with NASM
2. Compiles Odin kernel with freestanding target
3. Links objects according to linker script
4. Creates bootable ISO with GRUB

### Odin Kernel Details

The kernel is compiled with these Odin flags:

- `-target:freestanding_i386` - No OS dependencies
- `-no-bounds-check` - Disable runtime bounds checking
- `-no-crt` - No C runtime
- `-default-to-nil-allocator` - No default allocator
- `-no-entry-point` - Custom entry from assembly

## Evangelion References

The kernel includes numerous references to Neon Genesis Evangelion:

- **MAGI System**: The three supercomputers CASPER, MELCHIOR, and BALTHASAR
- **NERV OS**: The fictional organization's operating system
- **Pattern Blue**: Angel detection status
- **AT Field**: Absolute Terror Field references
- **Terminal Dogma**: The deepest level of NERV headquarters

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by Neon Genesis Evangelion by Hideaki Anno
- Built with the Odin programming language by gingerBill
- Multiboot specification by Free Software Foundation

---

_"God's in his heaven, all's right with the world."_ - NERV motto
