# MAGIos Build System Documentation

## Overview

The MAGIos build system has been simplified to use centralized configuration and provide clear, fast feedback. The system maintains the Evangelion aesthetic while being more succinct and maintainable.

## Build Files Structure

```
MAGIos/
├── build.sh          # Main build script with dependency management
├── Makefile          # Core build targets and compilation
├── build.config      # Centralized configuration (for reference)
└── BUILD_SYSTEM.md   # This documentation
```

## Variable Definitions and Sources

### Toolchain Variables
**Defined in:** Both `build.sh` and `Makefile`
**Source:** Hardcoded values based on project requirements

| Variable | Value | Purpose |
|----------|-------|---------|
| `TOOLCHAINS` | `org.swift.62202505141a` | Swift development toolchain identifier |
| `ASM` | `nasm` | Assembler executable |
| `CC` | `i686-elf-gcc` | Cross-compiler for 32-bit x86 |
| `LD` | `i686-elf-ld` | Linker for target architecture |
| `SWIFT` | `swiftc` | Swift compiler executable |

### Architecture Variables
**Defined in:** Both `build.sh` and `Makefile`
**Source:** Project specification (32-bit x86 OS)

| Variable | Value | Purpose |
|----------|-------|---------|
| `TARGET_ARCH` | `i686-unknown-none-elf` | Target triple for cross-compilation |
| `TARGET_BITS` | `32` | Target architecture bit width |

### Compilation Flags
**Defined in:** `Makefile` only
**Source:** Requirements for embedded/kernel development

| Variable | Value | Purpose |
|----------|-------|---------|
| `ASMFLAGS` | `-f elf32` | Assembly output format |
| `CFLAGS` | `-m32 -ffreestanding -fno-stack-protector -fno-builtin -nostdlib -Wall -Wextra -std=c99` | C compilation for freestanding environment |
| `LDFLAGS` | `-m elf_i386 -T linker.ld` | Linker flags with custom linker script |
| `SWIFTFLAGS` | `-enable-experimental-feature Embedded -target i686-unknown-none-elf ...` | Swift Embedded feature flags |

### Directory Structure
**Defined in:** Both `build.sh` and `Makefile`
**Source:** Project organization

| Variable | Value | Purpose |
|----------|-------|---------|
| `SRCDIR` | `src` | Source code directory |
| `SWIFT_SRCDIR` | `src/swift` | Swift source files |
| `BUILDDIR` | `build` | Build output directory |
| `ISODIR` | `iso` | ISO staging directory |

### Build Targets
**Defined in:** Both `build.sh` and `Makefile`
**Source:** Build system design

| Variable | Value | Purpose |
|----------|-------|---------|
| `KERNEL_BINARY` | `build/kernel.bin` | Final kernel executable |
| `ISO_FILE` | `magios.iso` | Bootable ISO image |

### MAGI System Names
**Defined in:** Both `build.sh` and `Makefile`
**Source:** Neon Genesis Evangelion theming

| Variable | Value | Purpose |
|----------|-------|---------|
| `MAGI_CASPER` | `CASPER` | First MAGI computer name |
| `MAGI_MELCHIOR` | `MELCHIOR` | Second MAGI computer name |
| `MAGI_BALTHASAR` | `BALTHASAR` | Third MAGI computer name |

### Version Information
**Defined in:** Both `build.sh` and `Makefile`
**Source:** Project metadata

| Variable | Value | Purpose |
|----------|-------|---------|
| `MAGIOS_VERSION` | `0.0.1` | Current version number |
| `MAGIOS_CODENAME` | `Terminal Dogma` | Version codename |

### Build Behavior Flags
**Defined in:** `Makefile` only
**Source:** User experience design

| Variable | Value | Purpose |
|----------|-------|---------|
| `SILENT_CHECKS` | `true` | Minimize verbose output during checks |
| `SHOW_PROGRESS` | `true` | Display build progress messages |
| `USE_MAGI_THEMING` | `true` | Enable Evangelion-themed output |

## Build Process Flow

### 1. Dependency Management (`build.sh`)
- Platform verification (macOS required)
- Tool availability checking
- Automatic installation via Homebrew
- Swift development snapshot verification

### 2. Compilation (`Makefile`)
- **Assembly**: Boot code compiled with NASM
- **C Code**: Kernel bootstrap with cross-compiler
- **Swift Code**: Embedded Swift kernel logic
- **Linking**: All objects combined into kernel binary

### 3. ISO Creation (`Makefile`)
- Kernel copied to ISO staging area
- GRUB configuration added
- Bootable ISO created with `grub-mkrescue`

## Usage Commands

| Command | Purpose | Variables Used |
|---------|---------|----------------|
| `./build.sh` | Build kernel and ISO | All build.sh variables |
| `./build.sh --run` | Build and launch in QEMU | All variables + QEMU config |
| `make all` | Build kernel only | Compilation variables |
| `make iso` | Create bootable ISO | Build targets + ISO config |
| `make clean` | Remove build artifacts | Directory variables |
| `make help` | Show available commands | Version and theming variables |

## Centralization Strategy

**Before Simplification:**
- Flags scattered across build.sh and Makefile
- Duplication between files
- Verbose tool checking
- Complex dependency installation

**After Simplification:**
- Single definition point for each variable type
- Shared constants between build.sh and Makefile
- Fast, silent tool verification
- Streamlined dependency management

## Configuration Sources Priority

1. **Hardcoded Values**: Core toolchain and architecture settings
2. **Project Requirements**: Compilation flags for embedded development
3. **User Experience**: Progress and theming flags
4. **External Dependencies**: Tool availability from system PATH

## Environment Dependencies

| Dependency | Detection Method | Installation Method |
|------------|------------------|---------------------|
| macOS | `$OSTYPE` check | Required (no auto-install) |
| Homebrew | `command -v brew` | Auto-install if missing |
| Swift Dev Snapshot | Version string parsing | Manual (link provided) |
| Cross-compiler | `command -v i686-elf-gcc` | Auto-install via Homebrew |
| QEMU | `command -v qemu-system-i386` | Auto-install via Homebrew |
| NASM | `command -v nasm` | Auto-install via Homebrew |

## Troubleshooting Variable Issues

### Common Problems:
1. **"Swift development snapshot required"** - Install from swift.org/download/#snapshots
2. **"Cross-compiler not found"** - Run `./build.sh` to auto-install
3. **"grub-mkrescue not found"** - Run `brew install grub`

### Debug Commands:
- `make check-tools` - Verify all dependencies
- `make swift-check` - Test Swift syntax
- `make help` - Show all variables and their current values

## Future Extensibility

To add new configuration variables:
1. Add to both `build.sh` and `Makefile`
2. Document in this file
3. Add to `make help` output if user-relevant
4. Consider environment variable override support
