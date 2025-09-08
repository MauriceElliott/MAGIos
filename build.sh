
#!/bin/bash

# Clean previous builds
rm -f kernel.bin boot.o kernel.o

echo "Building Swift kernel..."
swift build

echo "Assembling boot code..."  
# Assemble the boot code
nasm -f elf64 Sources/boot.asm -o boot.o

echo "Linking kernel..."
ld -T Sources/linker.ld -o kernel.bin boot.o adam.o

echo "Running MAGIos."
qemu-system-x86_64 -kernel kernel.bin

echo "Running kernel in QEMU..."
