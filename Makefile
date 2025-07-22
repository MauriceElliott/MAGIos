# MAGIos Makefile - Fixed Version
# Simple build system for MAGIos operating system

# === TOOLCHAIN CONFIGURATION ===
ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld

# === COMPILATION FLAGS ===
ASMFLAGS = -f elf32
CFLAGS = -m32 -ffreestanding -fno-stack-protector -fno-builtin -nostdlib -Wall -Wextra
LDFLAGS = -m elf_i386 -T linker.ld

# === DIRECTORIES ===
SRCDIR = src
BUILDDIR = build
ISODIR = iso

# === SOURCE FILES ===
C_SOURCES = $(wildcard $(SRCDIR)/*.c)
ASM_SOURCES = $(wildcard $(SRCDIR)/*.s)
C_OBJECTS = $(C_SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)
ASM_OBJECTS = $(ASM_SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)
OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

# === PHONY TARGETS ===
.PHONY: all clean iso run debug check-tools help

# === DEFAULT TARGET ===
all: check-tools $(BUILDDIR)/kernel.bin

# === TOOL VERIFICATION ===
check-tools:
	@echo "Checking build tools..."
	@which nasm > /dev/null || (echo "ERROR: nasm not found" && exit 1)
	@which qemu-system-i386 > /dev/null || (echo "ERROR: qemu not found" && exit 1)
	@which i686-elf-gcc > /dev/null || (echo "ERROR: i686-elf-gcc not found" && exit 1)
	@echo "All tools found!"

# === BUILD DIRECTORY ===
$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

# === COMPILATION RULES ===
$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	@echo "Compiling: $<"
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/%.o: $(SRCDIR)/%.s | $(BUILDDIR)
	@echo "Assembling: $<"
	$(ASM) $(ASMFLAGS) $< -o $@

# === KERNEL BINARY ===
$(BUILDDIR)/kernel.bin: $(OBJECTS)
	@echo "Linking kernel..."
	$(LD) $(LDFLAGS) -o $@ $^

# === ISO CREATION ===
iso: $(BUILDDIR)/kernel.bin
	@echo "Creating ISO..."
	@mkdir -p $(ISODIR)/boot/grub
	cp $(BUILDDIR)/kernel.bin $(ISODIR)/boot/
	cp grub.cfg $(ISODIR)/boot/grub/
	i686-elf-grub-mkrescue -o magios.iso $(ISODIR)

# === RUN IN QEMU ===
run: iso
	qemu-system-i386 -cdrom magios.iso

# === DEBUG MODE ===
debug: iso
	qemu-system-i386 -cdrom magios.iso -s -S

# === CLEANUP ===
clean:
	rm -rf $(BUILDDIR) $(ISODIR) magios.iso

# === HELP ===
help:
	@echo "MAGIos Build System"
	@echo "=================="
	@echo "Targets:"
	@echo "  all      - Build kernel binary"
	@echo "  iso      - Create bootable ISO"
	@echo "  run      - Run in QEMU"
	@echo "  debug    - Debug mode"
	@echo "  clean    - Clean build files"
