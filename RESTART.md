# MAGIos - Evangelion-Themed Swift Kernel

## Project Vision

A minimal bare-metal x86_64 operating system kernel written in standard Swift with Evangelion theming. The goal is to boot and display "WELCOME TO TERMINAL DOGMA" using native Swift string literals.

## Core Objective

Boot a Swift kernel that:

1. Displays "WELCOME TO TERMINAL DOGMA" in green text
2. Uses actual Swift string literals (not byte arrays)
3. Writes directly to VGA text buffer at 0xB8000
4. Halts cleanly

## Why x86_64 and Standard Swift?

- **Swift is natively designed for 64-bit platforms** - better toolchain support
- **ARC (Automatic Reference Counting)** is deterministic and works well in kernel space
- **Community precedent** - swift-project1 proves this approach works
- **VGA text mode** at 0xB8000 is universally available and simple to use

## String Handling Strategy

The key insight from swift-project1 is that Swift strings can work in freestanding environments with minimal runtime support:

```swift
func printString(_ s: String, color: UInt8 = 0x0A) {
    let buffer = UnsafeMutablePointer<UInt16>(bitPattern: 0xB8000)!
    var cursor = 0

    for c in s.utf8 {
        let value = UInt16(color) << 8 | UInt16(c)
        buffer[cursor] = value
        cursor += 1
    }
}

// Usage in kernel:
let bootMessage = "WELCOME TO TERMINAL DOGMA"
printString(bootMessage)
```

## Project Structure

```
MAGIos/
├── Package.swift              # Swift package configuration
├── build.sh                   # Build script with --run flag
├── Sources/
│   ├── Kernel/
│   │   ├── main.swift        # Swift kernel entry point
│   │   ├── Display.swift     # VGA text output
│   │   └── System.swift      # Basic system functions
│   └── Boot/
│       ├── multiboot.s       # Multiboot header
│       ├── boot.s            # Assembly boot code
│       └── linker.ld         # Linker script
└── Qemu/
    └── run.sh               # Qemu execution script
```

## Implementation Plan

### 1. Assembly Foundation

- **Multiboot2 Header**: GRUB-compatible boot header
- **Boot Code**: Set up 64-bit mode, stack, jump to Swift `kmain`
- **Linker Script**: Load at 0x100000, define memory layout

### 2. Swift Kernel Core

**main.swift**:

```swift
@_silgen_name("kmain")
func kernelMain() -> Never {
    Display.clear()
    Display.print("WELCOME TO TERMINAL DOGMA")
    System.halt()
}
```

**Display.swift**:

- Direct VGA memory manipulation at 0xB8000
- Support for Swift String literals
- Green-on-black Terminal Dogma color scheme (0x0A)

**System.swift**:

- `halt()` function using inline assembly
- Minimal runtime support for Swift ARC

### 3. Build System

**build.sh**:

- Compile Swift with freestanding target
- Assemble boot files with NASM
- Link with custom script
- Generate bootable ISO with GRUB
- `--run` flag launches in Qemu

## Swift Runtime Requirements

Based on swift-project1, minimal runtime support needed:

- Basic allocation routines for ARC
- Panic handler for crashes
- No Foundation or standard library dependencies

## Evangelion Theming

- **Boot Message**: "WELCOME TO TERMINAL DOGMA"
- **Color Scheme**: Green on black (VGA color 0x0A)
- **Aesthetic**: Terminal Dogma computer interface

## Build Requirements

**macOS**:

- Xcode Command Line Tools
- Swift 5.9+
- NASM, GNU binutils (via Homebrew)
- Qemu

**Linux**:

- Swift toolchain
- build-essential, nasm, binutils
- qemu-system-x86

## Success Criteria

1. ✅ Kernel boots in Qemu
2. ✅ "WELCOME TO TERMINAL DOGMA" displays in green text
3. ✅ Uses Swift string literals (not byte arrays)
4. ✅ Kernel halts without crashing
5. ✅ Build system works cross-platform
6. ✅ No C code except minimal runtime shims

## Reference

**Swift-Project1**: https://github.com/spevans/swift-project1

- Proven Swift kernel architecture
- String handling in freestanding Swift
- Build system patterns
- Runtime requirements

---

_"The fate of destruction is also the joy of rebirth... in Swift."_
