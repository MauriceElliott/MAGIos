#!/bin/bash
# MAGIos Build Script - Terminal Dogma Build System
# Swift-first 32-bit OS kernel with Evangelion aesthetic

set -e

# === BUILD CONFIGURATION ===
export TOOLCHAINS=org.swift.62202505141a
ASM="nasm"
CC="i686-elf-gcc"
LD="i686-elf-ld"
SWIFT="swiftc"

TARGET_ARCH="i686-unknown-none-elf"
# === CENTRALIZED PATH CONFIGURATION ===
# Path constants for easier maintenance and updates
SRCDIR="src"
KERNEL_SRCDIR="$SRCDIR/kernel"
SWERNEL_SRCDIR="$SRCDIR/swernel"
SUPPORT_SRCDIR="$SRCDIR/support"
BUILDDIR="build"
ISODIR="iso"

# Legacy compatibility (updating gradually to swernel)
SWIFT_SRCDIR="$SWERNEL_SRCDIR"
KERNEL_BINARY="$BUILDDIR/kernel.bin"
ISO_FILE="magios.iso"

MAGI_CASPER="CASPER"
MAGI_MELCHIOR="MELCHIOR"
MAGI_BALTHASAR="BALTHASAR"
MAGIOS_VERSION="0.0.1"

SILENT_CHECKS=true
SHOW_PROGRESS=true

# === MAGI SYSTEM INITIALIZATION ===
echo ""
echo "========================================="
echo "MAGI SYSTEM STARTUP SEQUENCE INITIATED"
echo "Terminal Dogma Build System"
echo "========================================="
echo ""

# === PLATFORM VERIFICATION ===
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ ERROR: macOS required for MAGIos development"
    exit 1
fi

# === DEPENDENCY FUNCTIONS ===
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$([[ -f "/opt/homebrew/bin/brew" ]] && /opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
    fi
}

check_tools() {
    local missing_tools=()

    # Check each required tool
    for tool in nasm qemu swiftc; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done

    # Check cross-compiler separately
    if ! command -v i686-elf-gcc &> /dev/null; then
        missing_tools+=(i686-elf-gcc)
    fi

    # Check grub separately
    if ! command -v i686-elf-grub-mkrescue &> /dev/null && ! command -v grub-mkrescue &> /dev/null; then
        missing_tools+=(grub)
    fi

    # Install missing tools
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "Installing missing tools: ${missing_tools[*]}"
        install_homebrew

        for tool in "${missing_tools[@]}"; do
            case $tool in
                i686-elf-gcc)
                    brew tap nativeos/i686-elf-toolchain 2>/dev/null || true
                    brew install i686-elf-binutils i686-elf-gcc 2>/dev/null || echo "⚠️ Cross-compiler installation may need manual setup"
                    ;;
                grub)
                    brew install i686-elf-grub 2>/dev/null || brew install grub 2>/dev/null || echo "⚠️ Failed to install grub"
                    ;;
                *)
                    brew install $tool 2>/dev/null || echo "⚠️ Failed to install $tool"
                    ;;
            esac
        done
    fi
}

verify_swift() {
    if ! command -v swiftc &> /dev/null; then
        echo "❌ ERROR: Swift compiler not found"
        echo "Install Swift from: https://www.swift.org/download/"
        exit 1
    fi

    # Check if it's a development version (preferred)
    if ! swift --version | grep -q "experimental\|development\|main"; then
        echo "⚠️  WARNING: Release Swift detected, development snapshot recommended"
        echo "   For full Embedded Swift support, install development snapshot from:"
        echo "   https://www.swift.org/download/#snapshots"
        echo "   Continuing with current version..."
        echo ""
    fi
}

# === TOOL VERIFICATION ===
echo "${MAGI_CASPER}... Checking toolchain"
check_tools

echo "${MAGI_MELCHIOR}... Verifying Swift"
verify_swift

echo "${MAGI_BALTHASAR}... Initializing build system"
echo ""

if [ "$SILENT_CHECKS" != "true" ]; then
    echo "All MAGI subsystems operational ✅"
    echo ""
fi

# === BUILD PROCESS ===
echo "🔨 Building MAGIos Swift kernel..."

# Clean previous builds
[ -d "$BUILDDIR" ] && rm -rf "$BUILDDIR" "$ISODIR" "$ISO_FILE" 2>/dev/null || true

# Build using make
if make all; then
    echo "✅ Swift kernel compilation successful!"
    echo ""

    # Create ISO
    echo "📀 Creating Terminal Dogma ISO..."
    if make iso; then
        echo ""
        echo "========================================="
        echo "🎉 Terminal Dogma Operational!"
        echo "========================================="
        echo ""
        echo "MAGIos ${MAGIOS_VERSION} ready for deployment"
        echo "ISO: $ISO_FILE ($(ls -lh $ISO_FILE 2>/dev/null | awk '{print $5}' || echo 'unknown'))"
        echo ""
        echo "AT Field operational. Pattern Blue. 🤖"
        echo ""
    else
        echo "❌ ISO creation failed"
        exit 1
    fi
else
    echo "❌ Kernel compilation failed"
    echo ""
    echo "Debug: make swift-check    # Verify Swift syntax"
    echo "Debug: make check-tools    # Verify toolchain"
    exit 1
fi

# === AUTO-RUN ===
if [[ "$1" == "--run" ]] || [[ "$1" == "-r" ]]; then
    echo "🚀 Launching MAGIos in QEMU..."
    echo ""
    make run
fi

echo "Usage: ./build.sh [--run]"
echo "       make help    # Show all commands"
echo ""
echo "Terminal Dogma build complete. Ready for synchronization. 🎌"
