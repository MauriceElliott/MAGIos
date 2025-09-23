#!/bin/bash

# Create build directory
mkdir -p .build

# Clean previous builds
rm -f .build/kernel.bin .build/boot.o

echo "Building Swift kernel..."
swift build -c release --triple riscv64-unkown-elf 

echo "Assembling boot code..."  
# Assemble the boot code into .build directory
riscv64-unknown-elf-as Sources/Pattern/boot.s -o .build/boot.o

if [ $? -ne 0 ]; then
    echo "Assembly failed!"
    exit 1
fi

echo "Linking kernel..."
SWIFT_OBJS=$(find .build/riscv64-unkown-elf/release -name "*.o")
# Run Linker
riscv64-unknown-elf-ld -T Sources/Pattern/linker.ld -o .build/kernel.bin .build/boot.o $SWIFT_OBJS

if [ $? -ne 0 ]; then
    echo "Linking failed!"
    exit 1
fi

echo "Kernel built successfully!"
echo "Running kernel in Qemu"
qemu-system-riscv64 -machine virt -kernel .build/kernel.bin -serial stdio -no-reboot -no-shutdown
