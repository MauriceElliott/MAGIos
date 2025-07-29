#!/bin/bash
# MAGIos Build Script - Terminal Dogma Build System
# See BUILD_SCRIPT_DOCUMENTATION at bottom for detailed documentation

set -e

# SWIFT_ENVIRONMENT_SETUP
setup_swift_environment() {
    if command -v swiftly &> /dev/null; then
        echo "🔧 Setting up Swift development snapshot environment..."
        # Get current toolchain
        local current_toolchain=$(swiftly use 2>/dev/null)
        if echo "$current_toolchain" | grep -q "main-snapshot\|development"; then
            # Set environment variable to use swiftly
            export USE_SWIFTLY=1
            echo "✅ Using Swift development snapshot: $(echo "$current_toolchain" | cut -d' ' -f1)"
        else
            echo "⚠️  No development snapshot found, using system Swift"
        fi
    fi
}

# BUILD_CONFIGURATION
export TOOLCHAINS=org.swift.62202505141a
ASM="nasm"
CC="i686-elf-gcc"
LD="i686-elf-ld"
SWIFT="swiftc"

TARGET_ARCH="i686-unknown-none-elf"

# PATH_CONFIGURATION
SRCDIR="Sources"
KERNEL_SRCDIR="$SRCDIR/kernel"
SWERNEL_SRCDIR="$SRCDIR/swernel"
SUPPORT_SRCDIR="$SRCDIR/support"
BUILDDIR="build"
ISODIR="iso"
SWIFT_SRCDIR="$SWERNEL_SRCDIR"
KERNEL_BINARY="$BUILDDIR/kernel.bin"
ISO_FILE="magios.iso"

# BUILD_CONFIG_FILES
LINKER_SCRIPT="$SRCDIR/linker.ld"
GRUB_CONFIG="$SRCDIR/grub.cfg"

MAGI_CASPER="CASPER"
MAGI_MELCHIOR="MELCHIOR"
MAGI_BALTHASAR="BALTHASAR"

# COLOR_CODES
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# DEPENDENCY_INSTALLATION
install_deps_macos() {
    echo "Installing macOS dependencies..."

    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$([[ -f "/opt/homebrew/bin/brew" ]] && /opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
    fi

    local tools_to_install=()

    for tool in nasm qemu; do
        if ! brew list $tool &>/dev/null; then
            tools_to_install+=($tool)
        fi
    done

    if [ ${#tools_to_install[@]} -gt 0 ]; then
        echo "Installing missing tools: ${tools_to_install[*]}"
        brew install "${tools_to_install[@]}"
    fi

    if ! command -v i686-elf-gcc &> /dev/null; then
        echo "Installing cross-compiler toolchain..."
        brew tap nativeos/i686-elf-toolchain
        brew install i686-elf-toolchain
    fi
}

# TOOL_VERIFICATION
check_tools() {
    local missing_tools=()

    for tool in nasm qemu-system-i386 swiftc; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done

    if ! command -v i686-elf-gcc &> /dev/null; then
        missing_tools+=(i686-elf-gcc)
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "Missing tools: ${missing_tools[*]}"
        case "$(uname)" in
            Darwin) install_deps_macos ;;
            *) echo "Please install missing tools manually" && exit 1 ;;
        esac
    fi
}

# SWIFT_VERIFICATION
verify_swift() {
    if ! command -v swiftc &> /dev/null; then
        echo "❌ ERROR: Swift compiler not found"
        echo "Install Swift from: https://www.swift.org/download/"
        exit 1
    fi

    # Check if we're using a development snapshot
    local swift_version
    if [ "$USE_SWIFTLY" = "1" ]; then
        swift_version=$(swiftly run swift --version)
    else
        swift_version=$(swift --version)
    fi

    if echo "$swift_version" | grep -q "experimental\|development\|main\|snapshot\|dev"; then
        echo "✅ Using Swift development snapshot"
        echo "   Version: $(echo "$swift_version" | head -1)"
    else
        echo "⚠️  WARNING: Release Swift detected, development snapshot recommended"
        echo "   For full Embedded Swift support, install development snapshot from:"
        echo "   https://www.swift.org/download/#snapshots"
        echo "   Continuing with current version..."
        echo ""
    fi
}

# BUILD_FUNCTIONS
build_kernel() {
    echo -e "${CYAN}🔨 Building MAGIos Swift kernel...${NC}"
    make all
    echo -e "${GREEN}✅ Swift kernel compilation successful!${NC}"
    echo ""
}

create_iso() {
    echo -e "${BLUE}📀 Creating Terminal Dogma ISO...${NC}"
    make iso
    echo ""
}

run_qemu() {
    echo -e "${PURPLE}🚀 Launching MAGIos in QEMU...${NC}"
    echo -e "   ${CYAN}AT Field operational. Pattern Blue.${NC}"
    echo ""
    make run
}

test_qemu() {
    echo -e "${YELLOW}🧪 Testing MAGIos kernel in headless mode...${NC}"
    echo -e "   ${CYAN}Terminal Dogma diagnostic sequence initiated${NC}"
    echo -e "   ${PURPLE}Output will appear below (timeout: 15s)${NC}"
    echo ""
    echo "========================================="
    make test
    echo "========================================="
    echo -e "${GREEN}✅ Kernel test completed${NC}"
    echo ""
}

# MAIN_SCRIPT
main() {
    echo "========================================="
    echo "MAGI SYSTEM STARTUP SEQUENCE INITIATED"
    echo "Terminal Dogma Build System"
    echo "========================================="
    echo ""

    # Set up Swift development snapshot environment first
    setup_swift_environment

    echo -e "${CYAN}$MAGI_CASPER... Checking toolchain${NC}"
    check_tools

    echo -e "${YELLOW}$MAGI_MELCHIOR... Verifying Swift${NC}"
    verify_swift

    echo -e "${PURPLE}$MAGI_BALTHASAR... Initializing build system${NC}"
    echo ""

    build_kernel
    create_iso

    if [[ "$1" == "--run" ]]; then
        run_qemu
    elif [[ "$1" == "--test" ]]; then
        test_qemu
    fi

    echo "========================================="
    echo -e "${GREEN}🎉 Terminal Dogma Operational!${NC}"
    echo "========================================="
    echo ""
    echo "MAGIos 0.0.1 ready for deployment"
    echo "ISO: $ISO_FILE ($(ls -lh $ISO_FILE 2>/dev/null | awk '{print $5}' || echo 'Unknown size'))"
    echo ""
    echo -e "${CYAN}AT Field operational. Pattern Blue.${NC} 🤖"
    echo ""
    echo "Usage: ./build.sh [--run|--test]"
    echo "       make help    # Show all commands"
    echo ""
    echo -e "${PURPLE}Terminal Dogma build complete. Ready for synchronization.${NC} 🎌"
}

main "$@"

#
# BUILD_SCRIPT_DOCUMENTATION ===
#
# SWIFT_ENVIRONMENT_SETUP:
# setup_swift_environment: Configures Swift development snapshot environment
# Uses swiftly to locate and activate the latest development snapshot
# Sets PATH to prioritize development snapshot over system Swift
# Provides fallback to system Swift if snapshots unavailable
#
# BUILD_CONFIGURATION:
# Sets up the toolchain environment for cross-compilation
# export TOOLCHAINS: Specifies Swift toolchain version for embedded Swift
# Tool variables: Defines cross-compiler and assembler tools
# TARGET_ARCH: Target architecture for embedded Swift compilation
#
# PATH_CONFIGURATION:
# Centralized path definitions for easier maintenance and updates
# SRCDIR: Main source directory
# KERNEL_SRCDIR: C kernel source location
# SWERNEL_SRCDIR: Swift kernel (swernel) source location
# SUPPORT_SRCDIR: Support library location
# Legacy compatibility maintained for gradual migration
#
# BUILD_CONFIG_FILES:
# LINKER_SCRIPT: Memory layout specification (linker.ld)
# GRUB_CONFIG: GRUB bootloader configuration (grub.cfg)
#
# COLOR_CODES:
# ANSI color codes for styled terminal output
# Enhances readability and provides Evangelion-themed aesthetic
#
# DEPENDENCY_INSTALLATION:
# install_deps_macos: Automatically installs required tools on macOS
# Uses Homebrew package manager
# Installs cross-compiler toolchain from custom tap
# Checks for existing installations to avoid duplicates
#
# TOOL_VERIFICATION:
# check_tools: Verifies all required build tools are available
# Automatically triggers installation on supported platforms
# Reports missing tools and guides manual installation
#
# SWIFT_VERIFICATION:
# verify_swift: Checks Swift compiler availability and version
# Sets up development snapshot environment via setup_swift_environment
# Detects if development snapshot is active vs release version
# Embedded Swift requires development snapshot for full feature support
#
# BUILD_FUNCTIONS:
# build_kernel: Compiles the Swift kernel using Makefile
# create_iso: Creates bootable ISO image
# run_qemu: Launches the kernel in QEMU emulator with GUI
# test_qemu: Runs kernel in headless QEMU for automated testing
#
# MAIN_SCRIPT:
# Coordinates the entire build process
# Sets up Swift development snapshot environment first
# Displays MAGI system startup sequence (Evangelion theme)
# Handles command line arguments (--run flag)
# Provides status updates and final summary
# Shows usage information and build results
#
# EVANGELION_THEMING:
# MAGI system references throughout (CASPER, MELCHIOR, BALTHASAR)
# "Terminal Dogma" and "AT Field" references
# Color-coded output matching anime aesthetic
# Japanese flag emoji for completion message
