# MAGIos - Project Initialization and Development Guidelines

## Core Project Requirements

This document serves as the definitive guide for MAGIos development. **All development must adhere to these requirements without deviation.**

### 1. Operating System Specification

- **Language**: Pure Swift with assembly only when absolutely necessary
- **Architecture**: x86_64 based, but preferentially use 32-bit implementations where possible
- **Target**: Embedded Swift environment
- **Goal**: A bootable operating system that displays boot messages

### 2. Architecture Requirements

- **Primary Target**: x86_64 (64-bit capable)
- **Implementation Preference**: Use 32-bit x86 instructions where feasible
- **Rationale**: Leverage 64-bit as build target while maintaining 32-bit simplicity

### 3. Build System Requirements

- **Primary Build Tool**: `swift build` command
- **Configuration Location**: All build configuration MUST be in `Package.swift`
- **Restriction**: NO compiler configuration in build scripts
- **Maintenance**: Single source of truth for all build settings

### 4. Development Philosophy

- **No Pivoting**: If initial approach fails, DO NOT change the original plan
- **Seek Input**: When errors occur that suggest deviating from core directives, STOP and ask for guidance
- **Stay True**: Maintain adherence to requirements even when simpler alternatives appear

### 5. Success Criteria

**The ONLY requirement for success is:**

- System boots successfully
- Displays boot message using VGA text output
- Provides a method similar to: `WriteLine("custom message")`
- Message appears during boot sequence

**That's it. Nothing more complex is required.**

### 6. Reference Implementation

Based on RESTART.md, the target functionality should allow:

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

## Development Checkpoints

Before proceeding with any development stage, verify:

1. ✅ Are we still using pure Swift + minimal assembly?
2. ✅ Is all build configuration in Package.swift only?
3. ✅ Are we targeting x86_64 but preferring 32-bit where possible?
4. ✅ Are we using Embedded Swift?
5. ✅ Are we staying focused on just booting + VGA text output?
6. ✅ Are we following the original plan without deviation?

## Non-Requirements

The following are explicitly NOT required for this phase:

- Complex graphics
- File systems
- Network support
- Multi-tasking
- Memory management beyond basic needs
- Advanced interrupt handling
- Device drivers beyond VGA text

## Emergency Protocol

If development encounters issues that suggest abandoning core requirements:

1. **STOP** all development immediately
2. Document the specific issue encountered
3. Reference this INIT.md file
4. Seek guidance rather than pivot

## Success Definition

**Project is complete when:**

- `swift build` produces working kernel
- Kernel boots in QEMU/real hardware
- VGA text output function works
- Can display custom boot message

**Nothing else matters for this iteration.**
