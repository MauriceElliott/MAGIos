# MAGIos Swift Integration Guide

## Overview

This document describes the integration of **Embedded Swift** into the MAGIos operating system kernel. MAGIos now supports a hybrid C/Swift architecture where Swift handles high-level kernel operations while C manages low-level system initialization and hardware abstraction.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [File Structure](#file-structure)
- [Setup Instructions](#setup-instructions)
- [Build Process](#build-process)
- [Integration Details](#integration-details)
- [Development Workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)
- [Future Roadmap](#future-roadmap)

## Prerequisites

### Required Tools

1. **Swift Development Snapshot** (6.0-dev or main branch)
   - Download from: https://www.swift.org/download/#snapshots
   - **Important**: Release versions don't support Embedded Swift
   - Verify with: `swift --version` should show "6.0-dev" or "main"

2. **Cross-Compilation Toolchain**
   - `i686-elf-gcc` - Cross compiler for i686 ELF targets
   - `i686-elf-ld` - Cross linker
   - `nasm` - Netwide Assembler for boot code

3. **Build Tools**
   - `make` - Build automation
   - `qemu-system-i386` - x86 emulator for testing
   - `grub-mkrescue` or `xorriso` - ISO creation

### Platform-Specific Setup

#### Windows
```powershell
# Run the PowerShell setup script
.\build.ps1
```

#### macOS/Linux
```bash
# Run the bash setup script
./build.sh
```

## Architecture Overview

```
┌─────────────────────────────────────────┐
│             MAGIos Kernel               │
├─────────────────────────────────────────┤
│  Swift Kernel (High-level operations)  │
│  - VGA terminal management              │
│  - MAGI system display                  │
│  - Memory-safe operations               │
│  - Type-safe hardware abstraction      │
├─────────────────────────────────────────┤
│  C Bridge Layer (Interoperability)     │
│  - Swift/C function bridging           │
│  - Boot information processing          │
│  - Error handling and fallback         │
├─────────────────────────────────────────┤
│  C Bootstrap (Low-level initialization)│
│  - Multiboot header processing          │
│  - Stack setup and memory layout       │
│  - Hardware initialization             │
├─────────────────────────────────────────┤
│  Assembly Boot Code (System startup)   │
│  - Multiboot compliance                 │
│  - Protected mode setup                │
│  - Initial stack configuration         │
└─────────────────────────────────────────┘
```

## File Structure

```
MAGIos/
├── src/                          # C and Assembly sources
│   ├── boot.s                   # Assembly boot code (unchanged)
│   ├── kernel.c                 # Original C kernel (preserved)
│   └── kernel_swift.c           # New hybrid C/Swift kernel
├── swift-src/                   # Swift package directory
│   ├── Package.swift           # Swift package configuration
│   ├── CMakeLists.txt          # Alternative CMake build
│   └── Sources/MAGIosSwift/
│       ├── SwiftKernel.swift   # Main Swift kernel implementation
│       ├── SwiftKernelDemo.swift # Demo version for testing
│       └── include/
│           └── kernel_bridge.h  # C/Swift interop header
├── build.ps1                   # Windows build script
├── build.sh                    # macOS/Linux build script (existing)
├── Makefile                    # Original C-only Makefile
├── Makefile.swift             # Enhanced Swift-enabled Makefile
├── linker.ld                  # Original linker script
└── linker_swift.ld           # Swift-enabled linker script
```

## Setup Instructions

### 1. Install Embedded Swift Toolchain

#### Download Development Snapshot
```bash
# Visit https://www.swift.org/download/#snapshots
# Download the latest "Trunk Development (main)" toolchain
# Install and activate it as your default Swift toolchain
```

#### Verify Installation
```bash
swift --version
# Should output: Swift version 6.0-dev (or similar development version)
```

### 2. Install Cross-Compilation Tools

#### Windows (PowerShell)
```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install MSYS2 and cross-compiler
choco install msys2 -y
# Follow MSYS2 setup in build.ps1
```

#### macOS
```bash
# Install Homebrew cross-compiler
brew tap nativeos/i686-elf-toolchain
brew install i686-elf-binutils i686-elf-gcc nasm qemu
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install nasm qemu-system-x86 build-essential
# Install i686-elf cross-compiler from source or package manager
```

### 3. Clone and Build

```bash
git clone <repository-url>
cd MAGIos

# Test Swift package compilation
cd swift-src
swift package resolve
swift build --triple i686-unknown-none-elf -c release \
    -Xswiftc -enable-experimental-feature -Xswiftc Embedded

# Build complete kernel
cd ..
make -f Makefile.swift swift-only
```

## Build Process

### Build Modes

The project supports multiple build modes:

1. **Swift Mode** (Default): C bootstrap + Swift kernel
2. **C Mode**: Traditional C-only kernel (fallback)

### Build Commands

```bash
# Swift-enabled kernel (recommended)
make -f Makefile.swift swift-only

# C-only kernel (fallback)
make -f Makefile.swift c-only

# Build and run
make -f Makefile.swift swift-only run

# Build and debug
make -f Makefile.swift swift-only debug
```

### Build Process Details

1. **Swift Compilation**
   ```bash
   cd swift-src
   swift build --triple i686-unknown-none-elf -c release \
       -Xswiftc -enable-experimental-feature -Xswiftc Embedded \
       -Xswiftc -Xfrontend -Xswiftc -disable-objc-interop \
       -Xswiftc -nostdlib
   ```

2. **Object Extraction**
   ```bash
   ar x .build/release/libMAGIosSwift.a
   i686-elf-ld -r -o swift_kernel.o *.o
   ```

3. **C Compilation**
   ```bash
   i686-elf-gcc -m32 -ffreestanding -fno-stack-protector \
       -nostdlib -c kernel_swift.c -o kernel_swift.o
   ```

4. **Assembly**
   ```bash
   nasm -f elf32 boot.s -o boot.o
   ```

5. **Linking**
   ```bash
   i686-elf-ld -T linker_swift.ld -o kernel.bin \
       boot.o kernel_swift.o swift_kernel.o
   ```

## Integration Details

### C to Swift Function Calls

The C kernel calls Swift functions using the `@_cdecl` attribute:

**Swift Side:**
```swift
@_cdecl("swift_kernel_main")
public func swiftKernelMain() {
    // Swift kernel implementation
}
```

**C Side:**
```c
// Declaration in kernel_bridge.h
void swift_kernel_main(void);

// Usage in kernel_swift.c
void kernel_main(void) {
    // C initialization
    swift_kernel_main();  // Call Swift kernel
    // C cleanup and halt
}
```

### Swift to C Function Calls

Swift can call C functions through the bridging header:

**C Side:**
```c
void emergency_print(const char *message);
```

**Swift Side:**
```swift
// Import through bridging header
emergency_print("Error message")
```

### Memory Management

- **C Code**: Manual memory management, direct hardware access
- **Swift Code**: Embedded Swift mode with disabled ARC for performance
- **Shared Memory**: VGA buffer at 0xB8000 accessed by both C and Swift

### Calling Conventions

Both C and Swift code use the same calling conventions:
- **ABI**: i686 System V ABI
- **Stack**: 16KB stack shared between C and Swift
- **Registers**: Standard x86 register usage
- **Memory Layout**: Defined by `linker_swift.ld`

## Development Workflow

### 1. Adding New Swift Functions

1. **Define in Swift:**
   ```swift
   @_cdecl("my_new_function")
   public func myNewFunction(_ param: UInt32) -> UInt32 {
       // Implementation
   }
   ```

2. **Declare in Bridge Header:**
   ```c
   // kernel_bridge.h
   uint32_t my_new_function(uint32_t param);
   ```

3. **Use from C:**
   ```c
   // kernel_swift.c
   uint32_t result = my_new_function(42);
   ```

### 2. Testing Changes

```bash
# Quick syntax check
cd swift-src
swift build --triple i686-unknown-none-elf -c release

# Full build and test
make -f Makefile.swift swift-only test-swift

# Run in emulator
make -f Makefile.swift swift-only run
```

### 3. Debugging

```bash
# Debug mode
make -f Makefile.swift swift-only debug

# In another terminal
gdb
(gdb) target remote localhost:1234
(gdb) symbol-file build/kernel.bin
(gdb) break swift_kernel_main
(gdb) continue
```

## Troubleshooting

### Common Issues

#### 1. Swift Compilation Errors

**Problem**: "error: embedded Swift is not supported"
**Solution**: Ensure you're using a development snapshot, not release Swift

**Problem**: "undefined symbol: swift_kernel_main"
**Solution**: Check that `@_cdecl` attribute is correctly applied

#### 2. Linking Errors

**Problem**: "undefined reference to Swift symbols"
**Solution**: Verify Swift library is being extracted and linked correctly

**Problem**: "section `.swift5_protocols' can't be allocated"
**Solution**: Check that `linker_swift.ld` includes Swift metadata sections

#### 3. Runtime Issues

**Problem**: Kernel panic or triple fault
**Solution**:
- Check stack alignment (16-byte aligned)
- Verify memory layout doesn't overlap
- Ensure no Swift standard library calls

#### 4. VGA Output Issues

**Problem**: No display output from Swift
**Solution**:
- Verify VGA_MEMORY address (0xB8000)
- Check color byte format
- Ensure cursor position calculations are correct

### Debug Commands

```bash
# Show kernel symbols
i686-elf-nm build/kernel.bin | grep swift

# Show kernel sections
i686-elf-objdump -h build/kernel.bin

# Disassemble Swift code
i686-elf-objdump -d build/kernel.bin | grep -A 20 swift_kernel_main

# Check kernel size
i686-elf-size build/kernel.bin
```

## Future Roadmap

### Phase 1: Basic Integration (Current)
- [x] Swift VGA terminal output
- [x] MAGI system display
- [x] C/Swift interoperability
- [x] Build system integration

### Phase 2: Enhanced Features
- [ ] Swift interrupt handlers
- [ ] Swift memory management
- [ ] Advanced VGA effects (AT Field patterns)
- [ ] Swift-based device drivers

### Phase 3: Full Swift Kernel
- [ ] Minimal C bootstrap only
- [ ] Swift process management
- [ ] Swift file system
- [ ] Swift networking stack

### Long-term Goals
- [ ] SwiftUI-like kernel GUI framework
- [ ] Swift package manager for kernel modules
- [ ] Full Evangelion-themed desktop environment
- [ ] Real hardware deployment

## Performance Considerations

### Embedded Swift Optimizations

1. **Compile-time optimizations:**
   - Whole module optimization (`-whole-module-optimization`)
   - Function inlining (`@inline(__always)`)
   - Dead code elimination

2. **Runtime optimizations:**
   - No ARC overhead in embedded mode
   - Direct memory access without bounds checking
   - Minimal metadata for type system

3. **Size optimizations:**
   - Disabled reflection and runtime features
   - Minimal Swift runtime
   - Static linking only

### Memory Usage

- **C Code**: ~2KB compiled
- **Swift Code**: ~8KB compiled (including minimal runtime)
- **Total Kernel**: ~15KB (bootable, including multiboot header)
- **Runtime Memory**: 16KB stack + VGA buffer access

## Contributing

### Code Style

- **Swift**: Follow Swift API Design Guidelines
- **C**: Follow Linux kernel style for consistency
- **Comments**: Document hardware interfaces thoroughly

### Testing

1. Test both C-only and Swift modes
2. Verify VGA output correctness
3. Check memory usage and performance
4. Test on real hardware when possible

### Pull Request Process

1. Ensure all build modes work
2. Update documentation for new features
3. Add appropriate error handling
4. Test with both debug and release builds

## Conclusion

The MAGIos Swift integration brings modern language features to kernel development while maintaining the performance and control needed for system programming. The hybrid architecture allows gradual migration from C to Swift while preserving compatibility and reliability.

For questions or issues, please refer to the troubleshooting section or create an issue in the project repository.

---

**Terminal Dogma Activated** 🤖

*"The complementarity of Swift and C creates a new paradigm in kernel development, much like the harmonious operation of the MAGI system's three cores."*
