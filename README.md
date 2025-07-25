# MAGIos Swift Edition

![Logo](resources/MAGIos.png)

**A Swift-powered operating system kernel with Evangelion aesthetic**

MAGIos is an experimental operating system built entirely with **Embedded Swift**, bringing modern language features to kernel development while maintaining the iconic 90s anime tech aesthetic of Neon Genesis Evangelion.

![Screenshot](resources/firstLook.png)

## Features

- **🤖 Swift-First Kernel**: Built with Embedded Swift for memory safety and modern syntax
- **🎌 MAGI System Interface**: Authentic Evangelion-themed boot sequence
- **⚡ Direct Hardware Access**: VGA text mode control with Swift safety
- **🔧 Hybrid Architecture**: Minimal C bootstrap with Swift kernel logic
- **📱 macOS Development**: Optimized for macOS development environment

## Quickstart

### 🚀 Get Running in 5 Minutes

**Prerequisites:**

- **macOS** (Intel or Apple Silicon)
- **Swift Development Snapshot** (6.0-dev or main branch)
  - ⚠️ **Critical**: Release versions don't support Embedded Swift
  - Download: https://www.swift.org/download/#snapshots

### ⚡ Option 1: Automatic Setup (Recommended)

```bash
# Clone and auto-build
git clone <your-repo-url>
cd MAGIos

# Install everything and run
./build.sh --run
```

**That's it!** The script will:

1. Install missing dependencies via Homebrew
2. Verify Swift development snapshot
3. Build the Swift kernel
4. Create bootable ISO
5. Launch in QEMU

### 🔧 Option 2: Manual Build

```bash
# Install Swift development snapshot first from swift.org

# Install dependencies
brew install nasm qemu
brew tap nativeos/i686-elf-toolchain
brew install i686-elf-gcc

# Build and run
make all
make iso
make run
```

### ✅ Success Indicators

When everything works, you'll see:

```
========================================
MAGI SYSTEM STARTUP SEQUENCE INITIATED
========================================

     CASPER...      ONLINE
     MELCHIOR...    ONLINE
     BALTHASAR...   ONLINE

     MAGIos v0.0.1 - Swift Edition
     Boot Successful (Swift Kernel Active)

     Hello, World from Swift MAGIos!
     AT Field operational. Pattern Blue.
```

### 🚨 Common Issues

**"embedded Swift is not supported"**

- Install Swift **development snapshot**, not release version
- Visit: https://swift.org/download/#snapshots

**"i686-elf-gcc: command not found"**

```bash
brew tap nativeos/i686-elf-toolchain
brew install i686-elf-gcc
```

**Swift build fails**

```bash
swift build --triple i686-unknown-none-elf -c release
```

## Architecture

```
┌─────────────────────────────────┐
│        MAGIos Kernel            │
├─────────────────────────────────┤
│  Swift Kernel (Main Logic)     │
│  - VGA terminal management      │
│  - MAGI system interface        │
│  - Memory-safe operations       │
├─────────────────────────────────┤
│  C Bootstrap (Minimal)          │
│  - Multiboot compliance         │
│  - Hardware initialization      │
├─────────────────────────────────┤
│  Assembly Boot (System Start)   │
│  - Protected mode setup         │
│  - Stack configuration          │
└─────────────────────────────────┘
```

## What You'll See

When booted, MAGIos displays the iconic MAGI system startup:

```
======================================
MAGI SYSTEM STARTUP SEQUENCE INITIATED
======================================

     CASPER...      ONLINE
     MELCHIOR...    ONLINE
     BALTHASAR...   ONLINE

     MAGIos v0.0.1 - Swift Edition
     Boot Successful (Swift Kernel Active)

     Hello, World from Swift MAGIos!
     AT Field operational. Pattern Blue.
```

## Development

### Project Structure

```
MAGIos/
├── src/
│   ├── boot.s              # Assembly boot code
│   ├── kernel.c            # C bootstrap layer
│   ├── Kernel.swift        # Main Swift kernel
│   └── include/
│       └── kernel_bridge.h # C/Swift interop
├── Package.swift          # Embedded Swift config
├── build.sh               # macOS build script
├── Makefile              # Build system
└── linker.ld             # Linker script
```

### Build Commands

```bash
make all          # Build kernel
make iso          # Create bootable ISO
make run          # Build and run in QEMU
make debug        # Run with GDB debugging
make clean        # Clean build artifacts
make help         # Show all commands
```

### Adding Swift Features

1. **Edit Swift Code**: Modify `src/Kernel.swift`
2. **Export to C**: Use `@_cdecl("function_name")` attribute
3. **Declare in Header**: Add declaration to `src/include/kernel_bridge.h`
4. **Build and Test**: `make all && make run`
