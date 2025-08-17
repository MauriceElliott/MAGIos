#!/bin/bash
# MAGIos Build Script - Terminal Dogma Build System
# RISC-V 64-bit Odin-based kernel build system with Evangelion theming

set -e

# Build Configuration
ASM="riscv64-elf-as"
CC="riscv64-elf-gcc"
LD="riscv64-elf-ld"
OBJCOPY="riscv64-elf-objcopy"
ODIN="odin"

# Path Configuration
SRCDIR="src"
BUILDDIR="build"
KERNEL_BINARY="$BUILDDIR/kernel.bin"
KERNEL_ELF="$BUILDDIR/kernel.elf"

# Build Files
BOOT_ASM="$SRCDIR/core/boot.s"
INTERRUPTS_ASM="$SRCDIR/core/interrupts.s"
KERNEL_ODIN="$SRCDIR/core/adam.odin"
LINKER_SCRIPT="$SRCDIR/linker.ld"

# MAGI System Names
MAGI_CASPER="CASPER"
MAGI_MELCHIOR="MELCHIOR"
MAGI_BALTHASAR="BALTHASAR"

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Tool Verification
check_tools() {
    echo -e "${CYAN}$MAGI_CASPER... Checking RISC-V toolchain${NC}"

    local missing_tools=()

    for tool in qemu-system-riscv64 odin riscv64-elf-gcc riscv64-elf-ld riscv64-elf-as riscv64-elf-objcopy; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing tools: ${missing_tools[*]}${NC}"
        echo ""
        echo "Installation instructions:"
        echo "  - Odin: https://odin-lang.org/docs/install/"
        echo "  - RISC-V toolchain (macOS): brew tap riscv-software-src/riscv && brew install riscv64-elf-gcc"
        echo "  - RISC-V toolchain (Linux): sudo apt install gcc-riscv64-linux-gnu"
        echo "  - QEMU (macOS): brew install qemu"
        echo "  - QEMU (Linux): sudo apt install qemu-system-riscv64"
        exit 1
    fi

    echo -e "${GREEN}✅ All RISC-V tools available${NC}"
}

# Create Build Directories
create_directories() {
    echo -e "${YELLOW}$MAGI_MELCHIOR... Creating build directories${NC}"
    mkdir -p "$BUILDDIR"
}

# Clean Build
clean() {
    echo -e "${RED}🧹 Cleaning build artifacts...${NC}"
    rm -rf "$BUILDDIR"
    echo -e "${GREEN}✅ Clean complete${NC}"
}

# Compile Boot Assembly
compile_boot() {
    echo -e "${BLUE}📦 Compiling RISC-V boot assembly...${NC}"
    $ASM "$BOOT_ASM" -o "$BUILDDIR/boot.o"
    echo -e "${GREEN}✅ RISC-V boot assembly compiled${NC}"
}

# Compile CPU Assembly
compile_cpu() {
    echo -e "${BLUE}📦 Compiling RISC-V CPU assembly...${NC}"
    $ASM "$SRCDIR/core/cpu.s" -o "$BUILDDIR/cpu.o"
    echo -e "${GREEN}✅ RISC-V CPU assembly compiled${NC}"
}

# Compile Interrupts Assembly
compile_interrupts() {
    echo -e "${BLUE}📦 Compiling RISC-V interrupt assembly...${NC}"
    $ASM "$INTERRUPTS_ASM" -o "$BUILDDIR/interrupts.o"
    echo -e "${GREEN}✅ RISC-V interrupt assembly compiled${NC}"
}

# Compile Odin Kernel
compile_kernel() {
    echo -e "${PURPLE}🔨 Compiling Odin kernel package...${NC}"

    # Compile entire Odin package to object file
    # Using freestanding_riscv64 target for bare-metal kernel
    $ODIN build "$SRCDIR/core" \
        -out:"$BUILDDIR/kernel_odin.o" \
        -target:freestanding_riscv64 \
        -no-bounds-check \
        -disable-red-zone \
        -no-crt \
        -no-thread-local \
        -default-to-nil-allocator \
        -no-entry-point \
        -o:speed \
        -build-mode:obj

    echo -e "${GREEN}✅ Odin kernel package compiled${NC}"
}

# Link Kernel
link_kernel() {
    echo -e "${CYAN}🔗 Linking RISC-V kernel binary...${NC}"

    $LD -m elf64lriscv \
        -T "$LINKER_SCRIPT" \
        -o "$KERNEL_ELF" \
        "$BUILDDIR/boot.o" \
        "$BUILDDIR/cpu.o" \
        "$BUILDDIR/interrupts.o" \
        "$BUILDDIR/kernel_odin.o" \
        -nostdlib

    # Create flat binary for potential bare-metal boot
    $OBJCOPY -O binary "$KERNEL_ELF" "$KERNEL_BINARY"

    echo -e "${GREEN}✅ RISC-V kernel linked${NC}"
}

# Run in QEMU (with GUI window)
run_qemu() {
    echo -e "${PURPLE}🚀 Launching MAGIos on RISC-V in QEMU...${NC}"
    echo -e "   ${CYAN}AT Field operational. Pattern Blue. RISC-V sync rate nominal.${NC}"
    echo -e "   ${YELLOW}QEMU window will open. Kernel output with colors will appear in QEMU console.${NC}"
    echo -e "   ${YELLOW}Use Cmd+Q to exit QEMU${NC}"
    echo ""

    qemu-system-riscv64 \
        -machine virt \
        -cpu rv64 \
        -smp 1 \
        -m 128M \
        -device ramfb \
        -display cocoa \
        -serial stdio \
        -bios default \
        -kernel "$KERNEL_ELF"
}

# Test in QEMU (headless mode with timeout)
test_qemu() {
    echo -e "${YELLOW}🧪 Testing MAGIos RISC-V kernel in headless mode...${NC}"
    echo -e "   ${PURPLE}Output will appear below (timeout: 10s)${NC}"
    echo ""
    echo "========================================="

    # Run QEMU in headless mode with serial output
    timeout 10s qemu-system-riscv64 \
        -machine virt \
        -cpu rv64 \
        -smp 1 \
        -m 128M \
        -nographic \
        -serial mon:stdio \
        -bios default \
        -kernel "$KERNEL_ELF" \
        || true

    echo "========================================="
    echo -e "${GREEN}✅ RISC-V kernel test completed${NC}"
}

# Build Process
build() {
    echo -e "${CYAN}🔨 Building MAGIos RISC-V kernel...${NC}"

    create_directories
    compile_boot
    compile_cpu
    compile_interrupts
    compile_kernel
    link_kernel

    echo -e "${GREEN}✅ RISC-V build complete!${NC}"
}

# Main Script
main() {
    echo "MAGI SYSTEM STARTUP SEQUENCE INITIATED"
    echo "RISC-V Architecture - Pattern Blue"

    # Parse arguments
    case "$1" in
        --clean)
            clean
            exit 0
            ;;
        --test|--run)
            # Continue to build
            ;;
        "")
            # Just build
            ;;
        *)
            echo "Usage: $0 [--clean|--test|--run]"
            echo "  --clean  Remove all build artifacts"
            echo "  --test   Build and test in headless QEMU"
            echo "  --run    Build and run in QEMU with serial console"
            exit 1
            ;;
    esac

    # Check tools and build
    check_tools
    echo -e "${PURPLE}$MAGI_BALTHASAR... Initializing RISC-V build system${NC}"
    echo ""

    build

    # Run if requested
    if [[ "$1" == "--run" ]]; then
        run_qemu
    elif [[ "$1" == "--test" ]]; then
        test_qemu
    fi

    echo ""
    echo -e "${GREEN}🎉 Terminal Dogma Operational!${NC}"
    echo ""
    echo "MAGIos 0.1.0 ready for RISC-V deployment"
    echo "Kernel: $KERNEL_ELF ($(ls -lh $KERNEL_ELF 2>/dev/null | awk '{print $5}' || echo 'Unknown size'))"
    echo ""
    echo "Usage: ./build.sh [--clean|--test|--run]"
    echo ""
    echo -e "${PURPLE}Terminal Dogma RISC-V build complete. Ready for synchronization.${NC} 🎌"
}

# Run main function
main "$@"
