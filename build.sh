#!/bin/bash
# MAGIos Build Script - Terminal Dogma Build System
# Odin-based kernel build system with Evangelion theming

set -e

# Build Configuration
ASM="nasm"
CC="i686-elf-gcc"
LD="i686-elf-ld"
ODIN="odin"

# Path Configuration
SRCDIR="src"
BUILDDIR="build"
ISODIR="iso"
KERNEL_BINARY="$BUILDDIR/kernel.bin"
ISO_FILE="magios.iso"

# Build Files
BOOT_ASM="$SRCDIR/boot.s"
CPU_ASM="$SRCDIR/cpu.s"
KERNEL_ODIN="$SRCDIR/kernel.odin"
LINKER_SCRIPT="$SRCDIR/linker.ld"
GRUB_CONFIG="$SRCDIR/grub.cfg"

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
    echo -e "${CYAN}$MAGI_CASPER... Checking toolchain${NC}"

    local missing_tools=()

    for tool in nasm qemu-system-i386 odin i686-elf-gcc i686-elf-ld; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done

    # Check for grub-mkrescue or i686-elf-grub-mkrescue
    if ! command -v grub-mkrescue &> /dev/null && ! command -v i686-elf-grub-mkrescue &> /dev/null; then
        missing_tools+=(i686-elf-grub-mkrescue)
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing tools: ${missing_tools[*]}${NC}"
        echo ""
        echo "Installation instructions:"
        echo "  - Odin: https://odin-lang.org/docs/install/"
        echo "  - Cross-compiler: brew install i686-elf-gcc (macOS)"
        echo "  - NASM: brew install nasm (macOS)"
        echo "  - QEMU: brew install qemu (macOS)"
        echo "  - GRUB: brew install i686-elf-grub (macOS)"
        exit 1
    fi

    echo -e "${GREEN}✅ All tools available${NC}"
}

# Create Build Directories
create_directories() {
    echo -e "${YELLOW}$MAGI_MELCHIOR... Creating build directories${NC}"
    mkdir -p "$BUILDDIR"
    mkdir -p "$ISODIR/boot/grub"
}

# Clean Build
clean() {
    echo -e "${RED}🧹 Cleaning build artifacts...${NC}"
    rm -rf "$BUILDDIR" "$ISODIR" "$ISO_FILE"
    echo -e "${GREEN}✅ Clean complete${NC}"
}

# Compile Boot Assembly
compile_boot() {
    echo -e "${BLUE}📦 Compiling boot assembly...${NC}"
    $ASM -f elf32 "$BOOT_ASM" -o "$BUILDDIR/boot.o"
    echo -e "${GREEN}✅ Boot assembly compiled${NC}"
}

# Compile CPU Assembly
compile_cpu() {
    echo -e "${BLUE}📦 Compiling CPU assembly...${NC}"
    $ASM -f elf32 "$CPU_ASM" -o "$BUILDDIR/cpu.o"
    echo -e "${GREEN}✅ CPU assembly compiled${NC}"
}

# Compile Odin Kernel
compile_kernel() {
    echo -e "${PURPLE}🔨 Compiling Odin kernel...${NC}"

    # Compile Odin to object file
    # Using linux_i386 target as base for freestanding kernel
    $ODIN build "$KERNEL_ODIN" -file \
        -out:"$BUILDDIR/kernel_odin.o" \
        -target:linux_i386 \
        -no-bounds-check \
        -disable-red-zone \
        -no-crt \
        -no-thread-local \
        -default-to-nil-allocator \
        -no-entry-point \
        -o:speed \
        -build-mode:obj

    echo -e "${GREEN}✅ Odin kernel compiled${NC}"
}

# Link Kernel
link_kernel() {
    echo -e "${CYAN}🔗 Linking kernel binary...${NC}"

    $LD -m elf_i386 \
        -T "$LINKER_SCRIPT" \
        -o "$KERNEL_BINARY" \
        "$BUILDDIR/boot.o" \
        "$BUILDDIR/cpu.o" \
        "$BUILDDIR/kernel_odin.o" \
        -nostdlib

    echo -e "${GREEN}✅ Kernel linked${NC}"
}

# Create ISO
create_iso() {
    echo -e "${BLUE}📀 Creating Terminal Dogma ISO...${NC}"

    # Copy kernel and GRUB config
    cp "$KERNEL_BINARY" "$ISODIR/boot/"
    cp "$GRUB_CONFIG" "$ISODIR/boot/grub/"

    # Create ISO with GRUB - try different methods
    if command -v i686-elf-grub-mkrescue &> /dev/null; then
        echo "Using i686-elf-grub-mkrescue..."
        i686-elf-grub-mkrescue -o "$ISO_FILE" "$ISODIR" 2>/dev/null
    elif command -v grub-mkrescue &> /dev/null; then
        echo "Using grub-mkrescue..."
        grub-mkrescue -o "$ISO_FILE" "$ISODIR" 2>/dev/null
    else
        echo -e "${RED}❌ Unable to create ISO - missing grub tools${NC}"
        echo "Please install GRUB tools: brew install i686-elf-grub"
        exit 1
    fi

    if [ -f "$ISO_FILE" ]; then
        echo -e "${GREEN}✅ ISO created: $ISO_FILE${NC}"
    else
        echo -e "${RED}❌ Failed to create ISO file${NC}"
        exit 1
    fi
}

# Run in QEMU (GUI mode)
run_qemu() {
    echo -e "${PURPLE}🚀 Launching MAGIos in QEMU...${NC}"
    echo -e "   ${CYAN}AT Field operational. Pattern Blue.${NC}"
    echo ""

    qemu-system-i386 \
        -cdrom "$ISO_FILE" \
        -m 32M \
        -vga std \
        -display default,show-cursor=on
}

# Test in QEMU (headless mode)
test_qemu() {
    echo -e "${YELLOW}🧪 Testing MAGIos kernel in headless mode...${NC}"
    echo -e "   ${PURPLE}Output will appear below (timeout: 5s)${NC}"
    echo ""
    echo "========================================="

    # Run QEMU in headless mode with serial output
    timeout 5s qemu-system-i386 \
        -cdrom "$ISO_FILE" \
        -m 32M \
        -nographic \
        -serial mon:stdio \
        -display none \
        || true

    echo "========================================="
    echo -e "${GREEN}✅ Kernel test completed${NC}"
}

# Build Process
build() {
    echo -e "${CYAN}🔨 Building MAGIos kernel...${NC}"

    create_directories
    compile_boot
    compile_cpu
    compile_kernel
    link_kernel
    create_iso

    echo -e "${GREEN}✅ Build complete!${NC}"
}

# Main Script
main() {
    echo "MAGI SYSTEM STARTUP SEQUENCE INITIATED"

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
            echo "  --run    Build and run in QEMU with GUI"
            exit 1
            ;;
    esac

    # Check tools and build
    check_tools
    echo -e "${PURPLE}$MAGI_BALTHASAR... Initializing build system${NC}"
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
    echo "MAGIos 0.0.1 ready for deployment"
    echo "ISO: $ISO_FILE ($(ls -lh $ISO_FILE 2>/dev/null | awk '{print $5}' || echo 'Unknown size'))"
    echo ""
    echo "Usage: ./build.sh [--clean|--test|--run]"
    echo ""
    echo -e "${PURPLE}Terminal Dogma build complete. Ready for synchronization.${NC} 🎌"
}

# Run main function
main "$@"
