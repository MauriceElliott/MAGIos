# MAGIos Swift Edition

![Logo](resources/MAGIos.png)

**An experimental 32-bit operating system written in Swift, inspired by Neon Genesis Evangelion**

MAGIos is an art piece that explores what happens when you build an operating system kernel primarily in Swift, with the aesthetic and terminology of the MAGI supercomputer system from the 1990s anime _Neon Genesis Evangelion_. This is not practical software - it's an artistic and technical exploration.

![Screenshot](resources/firstLook.png)

## What This Is

- **🎨 Art Project**: An exploration of Swift in kernel development with Evangelion theming
- **🚀 Swift Kernel**: 32-bit OS kernel written primarily in Embedded Swift
- **🤖 MAGI Interface**: Boot sequence and terminology inspired by Evangelion's supercomputers
- **⚡ Educational**: Demonstrates memory-safe kernel programming concepts
- **📱 macOS-Optimized**: Development environment designed for macOS users

## Quick Start

### Requirements

- **macOS** (Intel or Apple Silicon)
- **Swift Development Snapshot** (6.0+ development branch)
  - ⚠️ **Important**: Release Swift versions do NOT support Embedded Swift
  - Download from: https://www.swift.org/download/#snapshots

### Simple Build & Run

```bash
git clone <repository-url>
cd MAGIos
./build.sh --run
```

The build script will automatically:

- Install missing dependencies via Homebrew
- Verify your Swift toolchain supports Embedded Swift
- Build the Swift kernel and create a bootable ISO
- Launch MAGIos in QEMU

### Expected Output

```
========================================
MAGI SYSTEM STARTUP SEQUENCE INITIATED
========================================

     CASPER...      ONLINE
     MELCHIOR...    ONLINE
     BALTHASAR...   ONLINE

     MAGIos v0.0.1 - Swift Edition
     AT Field operational. Pattern Blue.
```

### Troubleshooting

| Issue                             | Solution                                                                 |
| --------------------------------- | ------------------------------------------------------------------------ |
| "embedded Swift is not supported" | Install Swift development snapshot, not release                          |
| "i686-elf-gcc: command not found" | Run: `brew tap nativeos/i686-elf-toolchain && brew install i686-elf-gcc` |
| Build fails                       | Check that Xcode has the development toolchain selected                  |

## Technical Overview

MAGIos uses a layered architecture that allows Swift to run at the kernel level:

| Layer             | Language | Purpose                                    |
| ----------------- | -------- | ------------------------------------------ |
| **Swift Kernel**  | Swift    | Main OS logic, VGA control, MAGI interface |
| **C Bootstrap**   | C        | Multiboot compliance, hardware setup       |
| **Boot Assembly** | x86 ASM  | Protected mode, stack initialization       |

### Why This Matters

- **Memory Safety**: Swift's ownership model prevents common kernel bugs
- **Modern Syntax**: Clean, readable code in a traditionally low-level domain
- **Artistic Expression**: Demonstrates that systems programming can be beautiful
- **Educational Value**: Shows how high-level languages can work at the hardware level

## Development

### Project Structure

```
MAGIos/
├── src/
│   ├── boot.s                    # x86 assembly bootloader
│   ├── kernel.c                  # C bootstrap & hardware init
│   └── swift/
│       └── swift_kernel.swift    # Main Swift kernel logic
├── build.sh                      # Automated build script
├── Makefile                      # Build system
├── LLM_RULES.md                  # Guidelines for AI assistance
└── linker.ld                     # Memory layout specification
```

### Development Commands

| Command            | Purpose                     |
| ------------------ | --------------------------- |
| `./build.sh`       | Build kernel and ISO        |
| `./build.sh --run` | Build and launch in QEMU    |
| `make clean`       | Remove build artifacts      |
| `make debug`       | Launch with GDB debugging   |
| `make help`        | Show all available commands |

### Contributing

1. **Follow the Aesthetic**: Maintain Evangelion theming
2. **Swift First**: Use Swift for new features when possible
3. **Check LLM_RULES.md**: Guidelines for AI-assisted development
4. **Test in QEMU**: Verify changes boot and run correctly

### Adding Features

Most new functionality should be added to `src/swift/swift_kernel.swift`. Use the `@_cdecl` attribute to export Swift functions that can be called from C code.
