#!/bin/bash
# MAGIos Build Script - macOS Version
# Automated build system for MAGIos operating system on macOS

set -e  # Exit on any error

echo "========================================="
echo "MAGIos Build System for macOS"
echo "========================================="

# === PLATFORM CHECK ===
# CRITICAL: Ensure we're running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: This script is designed for macOS only."
    echo "For other systems, use the Makefile directly with appropriate tools."
    exit 1
fi

# === DEPENDENCY CHECKER FUNCTIONS ===
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found!"
        echo "Installing Homebrew (required for dependencies)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            # Apple Silicon Mac
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            # Intel Mac
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "✅ Homebrew found"
    fi
}

check_and_install_tool() {
    local tool_name=$1
    local brew_package=$2
    local check_command=${3:-$tool_name}

    if ! command -v "$check_command" &> /dev/null; then
        echo "❌ $tool_name not found, installing..."
        brew install "$brew_package"
        echo "✅ $tool_name installed"
    else
        echo "✅ $tool_name found"
    fi
}

install_cross_compiler() {
    if ! command -v i686-elf-gcc &> /dev/null; then
        echo "❌ Cross-compiler not found, installing..."

        # Try the homebrew tap first
        echo "Attempting to install via homebrew tap..."
        if brew tap nativeos/i686-elf-toolchain 2>/dev/null && \
           brew install i686-elf-binutils i686-elf-gcc 2>/dev/null; then
            echo "✅ Cross-compiler installed via homebrew tap"
        else
            echo "⚠️  Homebrew tap failed, trying alternative method..."

            # Try installing x86_64-elf-gcc as fallback
            if brew install x86_64-elf-gcc 2>/dev/null; then
                echo "✅ Installed x86_64-elf-gcc as alternative"
                echo "Note: Will use x86_64-elf-gcc with -m32 flag"

                # Create symbolic links for compatibility
                local brew_prefix=$(brew --prefix)
                if [[ ! -f "$brew_prefix/bin/i686-elf-gcc" ]]; then
                    ln -sf "$brew_prefix/bin/x86_64-elf-gcc" "$brew_prefix/bin/i686-elf-gcc" 2>/dev/null || true
                    ln -sf "$brew_prefix/bin/x86_64-elf-ld" "$brew_prefix/bin/i686-elf-ld" 2>/dev/null || true
                fi
            else
                echo "❌ Failed to install cross-compiler automatically"
                echo "Please install manually or check the README for instructions"
                echo "You can try: brew install gcc"
                exit 1
            fi
        fi
    else
        echo "✅ Cross-compiler found"
    fi
}

# === DEPENDENCY INSTALLATION ===
echo "Checking and installing dependencies..."
echo "-------------------------------------"

# Check Homebrew first
check_homebrew

# Install basic tools
check_and_install_tool "NASM (Assembler)" "nasm"
check_and_install_tool "QEMU (Emulator)" "qemu"
check_and_install_tool "xorriso (ISO creation)" "xorriso"

# Install cross-compiler (most complex part)
install_cross_compiler

echo ""
echo "✅ All dependencies installed successfully!"
echo ""

# === CREATE REQUIRED DIRECTORIES ===
echo "Setting up build environment..."
mkdir -p build src iso

# === BUILD PROCESS ===
echo "========================================="
echo "Building MAGIos Kernel..."
echo "========================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
make clean 2>/dev/null || true

# Build kernel binary
echo "🔨 Compiling kernel..."
if make all; then
    echo "✅ Kernel compilation successful!"
else
    echo "❌ Kernel compilation failed!"
    echo ""
    echo "Common issues:"
    echo "- Cross-compiler not properly installed"
    echo "- Source files missing or corrupted"
    echo "- Linker script errors"
    echo ""
    echo "Try running: make check-tools"
    exit 1
fi

# Create bootable ISO
echo "📀 Creating bootable ISO..."
if make iso; then
    echo "✅ ISO creation successful!"
    echo ""
    echo "========================================="
    echo "🎉 MAGIos Build Complete!"
    echo "========================================="
    echo ""
    echo "Your operating system is ready!"
    echo "ISO file: magios.iso"
    echo ""
    echo "To run MAGIos:"
    echo "  make run          # Run in QEMU emulator"
    echo "  make debug        # Run with debugging support"
    echo ""
    echo "To test in other environments:"
    echo "  - Boot from magios.iso in VirtualBox/VMware"
    echo "  - Write to USB and boot on real hardware (advanced)"
    echo ""
    echo "Welcome to Terminal Dogma! 🤖"
else
    echo "❌ ISO creation failed!"
    echo ""
    echo "The kernel binary was built successfully, but ISO creation failed."
    echo "This might be due to missing grub-mkrescue or xorriso."
    echo ""
    echo "You can still test the kernel binary directly:"
    echo "  qemu-system-i386 -kernel build/kernel.bin"
    exit 1
fi

# === FINAL SYSTEM CHECK (NON-CRITICAL) ===
echo ""
echo "System Information:"
echo "-------------------"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Architecture: $(uname -m)"
echo "Kernel Binary: build/kernel.bin ($(ls -lh build/kernel.bin 2>/dev/null | awk '{print $5}' || echo 'unknown size'))"
echo "ISO Image: magios.iso ($(ls -lh magios.iso 2>/dev/null | awk '{print $5}' || echo 'unknown size'))"
echo ""
echo "Happy hacking! 🚀"
