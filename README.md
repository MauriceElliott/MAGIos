# MAGIos Swift Edition

![Logo](resources/MAGIos.png)

**An experimental 32-bit operating system written in Swift, inspired by Neon Genesis Evangelion**

MAGIos is an art piece that explores what happens when you build an operating system kernel primarily in Swift, with the aesthetic and terminology of the MAGI supercomputer system from the 1990s anime _Neon Genesis Evangelion_. This is not practical software - it's an artistic and technical exploration.

![Screenshot](resources/firstLook.png)

## What This Is

- This is an educational piece, and a bit of an art project for me to learn how to build all sorts of software.
- I'm writing this using C and Swift, C because its a necessity, and Swift because I just love its ergonmics, I think they're a good fit for each other. That being said the features I'm using to make this possible are still experimental so we without being proped up by C I'm sure this wouldn't be possible.
- 32 bit because its complete enough to not hold me back while still being simple enough to learn with.
- I am developing this on mac but also use linux so will eventually port the build system to use a package manager.

## Quick Start

### Requirements

- **macOS** (Intel or Apple Silicon)
- **Swift Development Snapshot** (6.1+ development branch)
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

## Development

### Project Structure

```
MAGIos/
├── src/
│   ├── boot.s                    # x86 assembly bootloader
│   ├── grub.cfg                  # GRUB bootloader configuration
│   ├── linker.ld                 # Memory layout specification
│   ├── kernel/
│   │   ├── kernel.c              # C bootstrap & hardware init
│   │   └── include/
│   │       └── kernel_bridge.h   # C/Swift interoperability header
│   ├── swernel/
│   │   └── swernel.swift         # Swift kernel (MAGI system core)
│   └── support/
│       ├── cstdlib/              # C standard library extensions
│       └── swtdlib/              # Swift standard library extensions
├── build.sh                      # Automated build script
├── Makefile                      # Build system (with centralized paths)
└── LLM_RULES.md                  # Guidelines for AI assistance
```

### Development Commands

| Command            | Purpose                     |
| ------------------ | --------------------------- |
| `./build.sh`       | Build kernel and ISO        |
| `./build.sh --run` | Build and launch in QEMU    |
| `make clean`       | Remove build artifacts      |
| `make debug`       | Launch with GDB debugging   |
| `make help`        | Show all available commands |

## Next Development Steps

### 1. MAGI Interrupt Handling System

**Status: Planned**

Implement a hardware interrupt system with Evangelion theming for keyboard input, timer interrupts, and system events.

**Technical Details:**

- Set up Interrupt Descriptor Table (IDT) in cernel
- Implement keyboard interrupt handler for user input
- Add timer interrupts for system heartbeat
- Create Swift-safe interrupt wrapper functions
- MAGI-themed interrupt classification (Pattern Blue/Orange/etc.)

**User Experience:**

- Real-time keyboard input processing
- System responds to user commands
- Interrupt status displayed with Angel detection terminology
- Foundation for interactive MAGI command interface

### 2. MAGI Command Interface

**Status: Planned**

Build an interactive command-line interface that feels like operating the MAGI supercomputers from NERV headquarters.

**Technical Details:**

- Command parser and dispatcher in Swift
- MAGI-themed command set (status, diagnose, sync, etc.)
- Command history and auto-completion
- Multi-line command support for complex operations
- Integration with memory management system

**User Experience:**

```
MAGI> status
CASPER:    ONLINE - Pattern Blue nominal
MELCHIOR:  ONLINE - Memory utilization 23%
BALTHASAR: ONLINE - AT Field stable

MAGI> diagnose memory
Heap Status: 1,048,576 bytes total
Available:   805,432 bytes (76.8%)
Blocks:      12 allocated, 8 free
Integrity:   AT Field maintained ✓

MAGI> help
Available commands:
  status     - System status report
  diagnose   - Hardware diagnostics
  sync       - Synchronize MAGI cores
  eva        - Evangelion unit status
  angel      - Threat assessment
```

### 3. AT Field Memory Visualization

**Status: Planned**

Real-time memory monitoring and visualization system with Evangelion-inspired graphics and terminology.

**Technical Details:**

- Live heap fragmentation display
- Memory allocation/deallocation tracking
- Visual representation of memory blocks
- Performance metrics with MAGI terminology
- Memory leak detection ("Angel intrusion")

**User Experience:**

- ASCII art memory maps showing heap status
- Real-time updates during allocation/free operations
- Color-coded memory regions (allocated/free/corrupted)
- MAGI-style status reports with technical readouts
- Alerts for memory issues using Angel threat levels

**Example Output:**

```
AT FIELD MEMORY ANALYSIS
========================
Heap Map: [████████░░░░████░░░░░░██████████░░░░]
Status:   Pattern Blue - Nominal
Threats:  No Angel signatures detected

Block Details:
  0x100000-0x102000: EVA-01 Core [ALLOCATED]
  0x102000-0x104000: Free Space [AVAILABLE]
  0x104000-0x108000: MAGI Buffer [ALLOCATED]

Synchronization Rate: 98.3%
```

## Contributing

1. **Follow the Aesthetic**: Maintain Evangelion theming
2. **Swift First**: Use Swift for new features when possible
3. **Check LLM_RULES.md**: Guidelines for AI-assisted development
4. **Test in QEMU**: Verify changes boot and run correctly
