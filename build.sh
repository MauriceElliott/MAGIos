#!/bin/bash

set -e

# MAGIos Build and Run Script
# Orchestrates build process and QEMU execution
# All compiler configuration is maintained in Package.swift per INIT.md requirements

echo "=== MAGIos Build and Run ==="

# Clean any previous artifacts
if [ "$1" = "--clean" ]; then
    echo "Cleaning build artifacts..."
    rm -rf .build/
    echo "Clean complete."
    exit 0
fi

# Build Swift kernel using Package.swift configuration
echo "Building MAGIos kernel..."
echo "Using configuration from Package.swift..."
swift build --configuration release

# Verify build succeeded
if [ ! -f ".build/release/kernel" ]; then
    echo "Error: Swift build failed or kernel not found"
    exit 1
fi

echo "✅ Build successful!"

# Handle different run modes
if [ "$1" = "--test" ]; then
    echo "Running kernel test (demo mode)..."
    ./.build/release/kernel
    echo "Test complete."
elif [ "$1" = "--run" ] || [ "$1" = "" ]; then
    echo "Starting QEMU with MAGIos kernel..."
    echo "Note: Currently running in demo mode - VGA output will show in terminal"
    echo "Press Ctrl+C to exit"
    echo ""

    # For now, run in demo mode since we don't have bootable kernel yet
    # In the future, this will launch: qemu-system-x86_64 -kernel .build/release/kernel
    # After successful build, create kernel binary
    echo "Creating kernel binary..."
    objcopy -O binary .build/release/kernel kernel.bin

    echo "Starting QEMU..."
    qemu-system-i386 -kernel kernel.bin -serial stdio -display curses
else
    echo "Usage:"
    echo "  ./build.sh [--run|--test|--clean]"
    echo ""
    echo "  --run    Build and run kernel (default)"
    echo "  --test   Build and run test"
    echo "  --clean  Clean build artifacts"
fi

echo "=== Complete ==="
