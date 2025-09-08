#!/bin/bash

# Create build directory
mkdir -p .build

# Clean previous builds
rm -f .build/kernel.bin .build/boot.o

echo "Building Swift kernel..."
swift build -c release

echo "Assembling boot code..."  
# Assemble the boot code into .build directory
nasm -f elf64 Sources/boot.asm -o .build/boot.o

if [ $? -ne 0 ]; then
    echo "Assembly failed!"
    exit 1
fi

echo "Linking kernel..."
# Find the Swift object files
SWIFT_OBJS=$(find .build -name "*.o" -path "*/Adam.build/*")
# Link everything together into .build directory
ld -T Sources/linker.ld -o .build/kernel.bin .build/boot.o $SWIFT_OBJS

if [ $? -ne 0 ]; then
    echo "Linking failed!"
    exit 1
fi

echo "Kernel built successfully!"
echo "Running kernel in QEMU..."
qemu-system-x86_64 -kernel .build/kernel.bin
