# MAGIos Swift Integration - Quick Start Guide

## 🚀 Get Started in 5 Minutes

This guide will get your Evangelion-themed operating system running with Swift integration in just a few minutes.

## ⚡ Prerequisites Check

Before starting, verify you have these tools:

```bash
# Check Swift version (need development snapshot)
swift --version
# Should show: Swift version 6.0-dev or similar

# Check if cross-compiler tools are available
i686-elf-gcc --version    # Cross compiler
nasm --version            # Assembler
qemu-system-i386 --version   # Emulator
make --version            # Build system
```

**Don't have these?** Use our automated installer:
- **Windows**: `.\build.ps1`
- **macOS/Linux**: `./build.sh`

## 🎯 Quick Build & Run

### Option 1: Swift-Enabled Kernel (Recommended)

```bash
# Build the hybrid C/Swift kernel
make -f Makefile.swift swift-only

# Create bootable ISO
make -f Makefile.swift iso

# Run in emulator
make -f Makefile.swift run
```

### Option 2: One-Command Build & Run

```bash
# Build everything and launch immediately
make -f Makefile.swift swift-only run
```

### Option 3: PowerShell (Windows)

```powershell
# Build and run with our PowerShell script
.\build.ps1 -Run
```

## 🖥️ What You'll See

When successful, you'll see the MAGI system boot sequence:

```
======================================
MAGI SYSTEM STARTUP SEQUENCE INITIATED
======================================

     CASPER...      ONLINE
     MELCHIOR...      ONLINE
     BALTHASAR...      ONLINE

     MAGIos v0.0.1 - Swift Edition
     Boot Successful (Swift Kernel Active)

     System Status:
     - Kernel: Swift Embedded + C Assembly
     - Memory: 1MB+ physical (Swift managed)
     - VGA: 80x25 text mode (Swift controlled)
     - Runtime: Embedded Swift (no stdlib)

     Hello, World from Swift MAGIos!
     Swift kernel initialized successfully...
     AT Field operational. Pattern Blue.
     System entering infinite idle loop...
```

## 🔧 Development Workflow

### Test Your Swift Code First

```bash
# Quick syntax check
cd swift-src
swift build

# Run demo locally
swift run SwiftKernelDemo
```

### Build Different Versions

```bash
# C-only kernel (fallback)
make -f Makefile.swift c-only run

# Swift kernel (default)
make -f Makefile.swift swift-only run

# Debug mode (for GDB debugging)
make -f Makefile.swift swift-only debug
```

### Clean Build

```bash
# Clean everything
make -f Makefile.swift clean

# Force rebuild
make -f Makefile.swift clean swift-only
```

## 🚨 Common Issues & Quick Fixes

### Issue: "embedded Swift is not supported"
**Fix**: Install Swift development snapshot (6.0-dev), not release version
```bash
# Download from: https://swift.org/download/#snapshots
```

### Issue: "i686-elf-gcc: command not found"
**Fix**: Install cross-compilation toolchain
```bash
# Windows: Run .\build.ps1 to auto-install
# macOS: brew tap nativeos/i686-elf-toolchain && brew install i686-elf-gcc
```

### Issue: "undefined reference to swift_kernel_main"
**Fix**: Swift compilation failed, check Swift code syntax
```bash
cd swift-src && swift build
```

### Issue: Black screen in QEMU
**Fix**: Try different QEMU options
```bash
# Alternative QEMU command
qemu-system-i386 -cdrom magios.iso -vga std
```

## 📋 Project Structure Quick Reference

```
MAGIos/
├── build.ps1              # Windows installer/builder
├── Makefile.swift         # Swift-enabled build system
├── src/kernel_swift.c     # Hybrid C/Swift kernel
├── swift-src/             # Swift package
│   ├── Package.swift      # Swift configuration
│   └── Sources/MAGIosSwift/
│       └── SwiftKernel.swift  # Main Swift kernel code
└── linker_swift.ld       # Swift-compatible linker script
```

## ⚙️ Advanced Usage

### Custom Build Configurations

```bash
# Debug build with symbols
make -f Makefile.swift KERNEL_MODE=swift debug

# Size-optimized build
make -f Makefile.swift CFLAGS="-Os" swift-only

# Show build information
make -f Makefile.swift show-symbols size
```

### ISO Deployment

```bash
# Create ISO for real hardware
make -f Makefile.swift iso

# The magios.iso file can be:
# - Burned to CD/DVD
# - Written to USB drive
# - Used with virtual machines
```

## 🎯 Next Steps

Once you have the basic system running:

1. **Explore the Code**: Check out `swift-src/Sources/MAGIosSwift/SwiftKernel.swift`
2. **Modify the Display**: Change colors, add new messages, create animations
3. **Add Features**: Implement new Swift functions and call them from C
4. **Read the Docs**: See `SWIFT_INTEGRATION.md` for detailed technical info

## 🆘 Need Help?

- **Build Issues**: Check `SWIFT_INTEGRATION.md` troubleshooting section
- **Swift Questions**: Refer to Swift Embedded documentation
- **General OS Dev**: MAGIos follows standard OS development practices

## 🎉 Success Indicators

You'll know everything is working when:
- ✅ Swift demo compiles and runs locally
- ✅ Kernel builds without errors
- ✅ ISO boots in QEMU
- ✅ MAGI startup sequence displays
- ✅ "Hello, World from Swift MAGIos!" appears

**Congratulations! You're now running a Swift-powered operating system with full Evangelion theming.** 🤖

---

**Terminal Dogma Activated**
*Ready to explore the boundaries between human and machine code.*
