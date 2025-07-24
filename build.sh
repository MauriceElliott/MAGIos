#!/bin/bash
# MAGIos Build Script - Swift-First macOS Version
# Evangelion-themed operating system with Embedded Swift kernel
# Requires macOS with Homebrew

set -e  # Exit on any error

echo ""
echo "========================================="
echo "MAGI SYSTEM STARTUP SEQUENCE INITIATED"
echo "Terminal Dogma Build System - macOS"
echo "========================================="
echo ""

# === PLATFORM CHECK ===
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ ERROR: This script requires macOS"
    echo "MAGIos Swift kernel is optimized for macOS development"
    exit 1
fi

# === MAGI SUBSYSTEM STATUS ===
echo "Checking MAGI subsystems..."
echo ""

# === DEPENDENCY CHECKER FUNCTIONS ===
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "❌ CASPER ERROR: Homebrew not found"
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        echo "✅ CASPER: Homebrew installed"
    else
        echo "✅ CASPER: Homebrew operational"
    fi
}

check_swift_toolchain() {
    if ! command -v swift &> /dev/null; then
        echo "❌ MELCHIOR ERROR: Swift not found"
        echo ""
        echo "Please install Swift development snapshot:"
        echo "1. Visit: https://www.swift.org/download/#snapshots"
        echo "2. Download 'Trunk Development (main)' toolchain"
        echo "3. Install and select it in Xcode preferences"
        echo ""
        exit 1
    fi

    # Check if it's a development snapshot
    swift_version=$(swift --version 2>/dev/null || echo "unknown")
    if [[ ! "$swift_version" =~ (6\.0-dev|main) ]]; then
        echo "❌ MELCHIOR ERROR: Need Swift development snapshot"
        echo "Current version: $swift_version"
        echo ""
        echo "Embedded Swift requires development snapshot:"
        echo "1. Visit: https://www.swift.org/download/#snapshots"
        echo "2. Download 'Trunk Development (main)' toolchain"
        echo "3. Install and activate: export TOOLCHAINS=<toolchain-id>"
        echo ""
        exit 1
    fi

    echo "✅ MELCHIOR: Swift development toolchain operational"
    echo "   Version: $swift_version"
}

install_cross_compiler() {
    if ! command -v i686-elf-gcc &> /dev/null; then
        echo "❌ BALTHASAR ERROR: Cross-compiler not found"
        echo "Installing i686-elf toolchain..."

        # Try the official tap first
        if brew tap nativeos/i686-elf-toolchain 2>/dev/null && \
           brew install i686-elf-binutils i686-elf-gcc 2>/dev/null; then
            echo "✅ BALTHASAR: Cross-compiler installed"
        else
            echo "⚠️ Official tap failed, trying alternative..."
            # Fallback to building from source or alternative method
            brew install gcc
            echo "⚠️ BALTHASAR: Using system GCC with cross-compile flags"
            echo "   You may need to build i686-elf-gcc manually"
        fi
    else
        echo "✅ BALTHASAR: Cross-compiler operational"
    fi
}

install_build_tools() {
    local tools=("nasm" "qemu" "grub")

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "Installing $tool..."
            brew install "$tool" || echo "⚠️ Failed to install $tool"
        fi
    done

    echo "✅ Build tools operational"
}

# === DEPENDENCY INSTALLATION ===
echo "CASPER... CHECKING HOMEBREW"
check_homebrew
echo ""

echo "MELCHIOR... VERIFYING SWIFT TOOLCHAIN"
check_swift_toolchain
echo ""

echo "BALTHASAR... INSTALLING CROSS-COMPILER"
install_cross_compiler
echo ""

echo "Installing additional build tools..."
install_build_tools
echo ""

echo "========================================="
echo "All MAGI subsystems operational ✅"
echo "========================================="
echo ""

# === BUILD PROCESS ===
echo "🔨 Building MAGIos Swift kernel..."
echo ""

# Clean previous builds
if [ -d "build" ]; then
    echo "🧹 Cleaning previous builds..."
    make clean 2>/dev/null || true
fi

# Build the Swift kernel
echo "🔹 Compiling Swift kernel components..."
if make all; then
    echo ""
    echo "✅ MAGIos Swift kernel compilation successful!"
    echo ""
else
    echo ""
    echo "❌ Kernel compilation failed!"
    echo ""
    echo "Common issues:"
    echo "- Swift development snapshot not properly installed"
    echo "- Cross-compiler missing (try: brew install i686-elf-gcc)"
    echo "- Swift source syntax errors"
    echo ""
    echo "Debug commands:"
    echo "  make check-tools    # Verify all tools"
    echo "  make swift-check    # Check Swift syntax"
    echo ""
    exit 1
fi

# Create bootable ISO
echo "📀 Creating Terminal Dogma ISO..."
if make iso; then
    echo ""
    echo "========================================="
    echo "🎉 Terminal Dogma Operational!"
    echo "========================================="
    echo ""
    echo "MAGIos Swift Edition ready for deployment"
    echo "ISO: magios.iso ($(ls -lh magios.iso 2>/dev/null | awk '{print $5}' || echo 'unknown size'))"
    echo ""
    echo "Launch commands:"
    echo "  make run      # Boot in QEMU"
    echo "  make debug    # Debug with GDB"
    echo "  make test     # Quick test run"
    echo ""
    echo "AT Field operational. Pattern Blue. 🤖"
    echo ""
else
    echo ""
    echo "❌ ISO creation failed!"
    echo ""
    echo "The kernel compiled successfully but ISO creation failed."
    echo "This may be due to missing GRUB tools."
    echo ""
    echo "Install GRUB: brew install grub"
    echo ""
    echo "You can still test the kernel directly:"
    echo "  qemu-system-i386 -kernel build/kernel.bin"
    echo ""
    exit 1
fi

# === SYSTEM INFORMATION ===
echo "System Information:"
echo "-------------------"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Architecture: $(uname -m)"
echo "Swift Version: $(swift --version | head -1)"
echo "Kernel Binary: build/kernel.bin ($(ls -lh build/kernel.bin 2>/dev/null | awk '{print $5}' || echo 'not found'))"
echo ""

# === OPTIONAL AUTO-RUN ===
if [[ "$1" == "--run" ]] || [[ "$1" == "-r" ]]; then
    echo "🚀 Auto-launching MAGIos..."
    echo ""
    make run
fi

echo "Terminal Dogma build complete. Ready for synchronization. 🎌"
echo ""
echo "Usage:"
echo "  ./build.sh           # Build only"
echo "  ./build.sh --run     # Build and run"
echo "  make help            # Show all commands"
