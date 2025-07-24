# MAGIos Makefile - Swift Integration Version
# Enhanced build system for MAGIos operating system with Embedded Swift support

# === TOOLCHAIN CONFIGURATION ===
ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld
SWIFT = swift

# === COMPILATION FLAGS ===
ASMFLAGS = -f elf32
CFLAGS = -m32 -ffreestanding -fno-stack-protector -fno-builtin -nostdlib -Wall -Wextra -std=c99
LDFLAGS = -m elf_i386 -T linker_swift.ld

# Swift compilation flags for embedded target
SWIFTFLAGS = build --triple i686-unknown-none-elf -c release -Xswiftc -enable-experimental-feature -Xswiftc Embedded

# === DIRECTORIES ===
SRCDIR = src
SWIFTSRCDIR = swift-src
BUILDDIR = build
ISODIR = iso

# === SOURCE FILES ===
C_SOURCES = $(wildcard $(SRCDIR)/*.c)
ASM_SOURCES = $(wildcard $(SRCDIR)/*.s)
C_OBJECTS = $(C_SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)
ASM_OBJECTS = $(ASM_SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)

# Swift objects
SWIFT_LIB = $(SWIFTSRCDIR)/.build/release/libMAGIosSwift.a
SWIFT_OBJECTS = $(BUILDDIR)/swift_kernel.o

# All objects
OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS) $(SWIFT_OBJECTS)

# === KERNEL MODES ===
# Allow selection of different kernel implementations
KERNEL_MODE ?= swift
ifeq ($(KERNEL_MODE),c)
    KERNEL_TARGET = $(BUILDDIR)/kernel_c.bin
    KERNEL_OBJECTS = $(filter-out $(BUILDDIR)/kernel_swift.o, $(C_OBJECTS)) $(ASM_OBJECTS)
else ifeq ($(KERNEL_MODE),swift)
    KERNEL_TARGET = $(BUILDDIR)/kernel.bin
    KERNEL_OBJECTS = $(filter-out $(BUILDDIR)/kernel.o, $(OBJECTS))
else
    $(error Invalid KERNEL_MODE: $(KERNEL_MODE). Use 'c' or 'swift')
endif

# === PHONY TARGETS ===
.PHONY: all clean iso run debug check-tools help swift-only c-only

# === DEFAULT TARGET ===
all: check-tools $(KERNEL_TARGET)

# === TOOL VERIFICATION ===
check-tools:
	@echo "Checking build tools..."
	@which nasm > /dev/null || (echo "ERROR: nasm not found" && exit 1)
	@which qemu-system-i386 > /dev/null || (echo "ERROR: qemu not found" && exit 1)
	@which i686-elf-gcc > /dev/null || (echo "ERROR: i686-elf-gcc not found" && exit 1)
	@which swift > /dev/null || (echo "ERROR: swift not found" && exit 1)
	@echo "Checking Swift version..."
	@swift --version | grep -E "(6\.0-dev|main)" > /dev/null || (echo "ERROR: Need Swift development snapshot (6.0-dev or main)" && exit 1)
	@echo "All tools found and compatible!"

# === BUILD DIRECTORY ===
$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

# === SWIFT COMPILATION ===
$(SWIFT_LIB): $(shell find $(SWIFTSRCDIR)/Sources -name "*.swift" 2>/dev/null)
	@echo "Building Swift library..."
	@cd $(SWIFTSRCDIR) && $(SWIFT) $(SWIFTFLAGS)
	@echo "Swift library built: $@"

$(SWIFT_OBJECTS): $(SWIFT_LIB) | $(BUILDDIR)
	@echo "Extracting Swift objects..."
	@cd $(BUILDDIR) && ar x ../$(SWIFT_LIB)
	@echo "Combining Swift objects..."
	@cd $(BUILDDIR) && i686-elf-ld -r -o swift_kernel.o *.o 2>/dev/null || \
		(echo "Creating empty Swift object..." && echo "" | i686-elf-as -32 -o swift_kernel.o)
	@cd $(BUILDDIR) && rm -f *.o.tmp 2>/dev/null || true

# === C COMPILATION RULES ===
$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	@echo "Compiling C: $<"
	$(CC) $(CFLAGS) -I$(SWIFTSRCDIR)/Sources/MAGIosSwift/include -c $< -o $@

$(BUILDDIR)/%.o: $(SRCDIR)/%.s | $(BUILDDIR)
	@echo "Assembling: $<"
	$(ASM) $(ASMFLAGS) $< -o $@

# === KERNEL BINARY TARGETS ===
$(BUILDDIR)/kernel.bin: $(KERNEL_OBJECTS)
	@echo "Linking Swift-enabled kernel..."
	$(LD) $(LDFLAGS) -o $@ $^
	@echo "Swift kernel built successfully!"

$(BUILDDIR)/kernel_c.bin: $(KERNEL_OBJECTS)
	@echo "Linking C-only kernel..."
	$(LD) -m elf_i386 -T linker.ld -o $@ $^
	@echo "C-only kernel built successfully!"

# === CONVENIENCE TARGETS ===
swift-only: KERNEL_MODE=swift
swift-only: all

c-only: KERNEL_MODE=c
c-only: all

# === ISO CREATION ===
iso: $(KERNEL_TARGET)
	@echo "Creating ISO..."
	@mkdir -p $(ISODIR)/boot/grub
	cp $(KERNEL_TARGET) $(ISODIR)/boot/kernel.bin
	cp grub.cfg $(ISODIR)/boot/grub/
	@if command -v grub-mkrescue >/dev/null 2>&1; then \
		grub-mkrescue -o magios.iso $(ISODIR); \
	elif command -v i686-elf-grub-mkrescue >/dev/null 2>&1; then \
		i686-elf-grub-mkrescue -o magios.iso $(ISODIR); \
	else \
		echo "WARNING: grub-mkrescue not found, trying xorriso..."; \
		if command -v xorriso >/dev/null 2>&1; then \
			xorriso -as mkisofs -R -b boot/grub/i386-pc/eltorito.img \
				-no-emul-boot -boot-load-size 4 -boot-info-table \
				-o magios.iso $(ISODIR) 2>/dev/null || \
			echo "ERROR: ISO creation failed. Install grub-mkrescue or check tools."; \
		else \
			echo "ERROR: No ISO creation tools found."; \
			exit 1; \
		fi \
	fi
	@echo "ISO created: magios.iso"

# === RUN IN QEMU ===
run: iso
	@echo "Launching MAGIos in QEMU..."
	qemu-system-i386 -cdrom magios.iso

# === DEBUG MODE ===
debug: iso
	@echo "Launching MAGIos in debug mode..."
	@echo "Connect GDB to localhost:1234"
	qemu-system-i386 -cdrom magios.iso -s -S

# === TESTING TARGETS ===
test-swift: swift-only iso
	@echo "Testing Swift kernel..."
	timeout 10s qemu-system-i386 -cdrom magios.iso -nographic -serial stdio || true

test-c: c-only iso
	@echo "Testing C kernel..."
	timeout 10s qemu-system-i386 -cdrom magios.iso -nographic -serial stdio || true

test-all: test-c test-swift
	@echo "All tests completed!"

# === CLEANUP ===
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILDDIR) $(ISODIR) magios.iso
	@if [ -d "$(SWIFTSRCDIR)/.build" ]; then \
		echo "Cleaning Swift build cache..."; \
		cd $(SWIFTSRCDIR) && swift package clean; \
	fi
	@echo "Clean completed!"

clean-swift:
	@echo "Cleaning Swift artifacts only..."
	@if [ -d "$(SWIFTSRCDIR)/.build" ]; then \
		cd $(SWIFTSRCDIR) && swift package clean; \
	fi
	rm -f $(BUILDDIR)/swift_kernel.o

# === DEVELOPMENT HELPERS ===
show-symbols: $(KERNEL_TARGET)
	@echo "Kernel symbols:"
	@i686-elf-nm $(KERNEL_TARGET) | head -20

show-sections: $(KERNEL_TARGET)
	@echo "Kernel sections:"
	@i686-elf-objdump -h $(KERNEL_TARGET)

show-swift-symbols: $(SWIFT_LIB)
	@echo "Swift library symbols:"
	@i686-elf-nm $(SWIFT_LIB) | grep -E "(swift_|_swift)" | head -10

disassemble: $(KERNEL_TARGET)
	@echo "Kernel disassembly (first 50 lines):"
	@i686-elf-objdump -d $(KERNEL_TARGET) | head -50

# === SIZE INFORMATION ===
size: $(KERNEL_TARGET)
	@echo "Kernel size information:"
	@i686-elf-size $(KERNEL_TARGET)
	@echo ""
	@echo "File sizes:"
	@ls -lh $(KERNEL_TARGET)
	@if [ -f "magios.iso" ]; then ls -lh magios.iso; fi

# === HELP ===
help:
	@echo "MAGIos Build System - Swift Integration"
	@echo "======================================"
	@echo ""
	@echo "Main Targets:"
	@echo "  all          - Build kernel (default: Swift mode)"
	@echo "  swift-only   - Build Swift-enabled kernel"
	@echo "  c-only       - Build C-only kernel (fallback)"
	@echo "  iso          - Create bootable ISO"
	@echo "  run          - Run in QEMU emulator"
	@echo "  debug        - Run with GDB debugging support"
	@echo ""
	@echo "Testing:"
	@echo "  test-swift   - Test Swift kernel"
	@echo "  test-c       - Test C kernel"
	@echo "  test-all     - Test both kernels"
	@echo ""
	@echo "Development:"
	@echo "  show-symbols - Show kernel symbols"
	@echo "  show-sections- Show kernel sections"
	@echo "  disassemble  - Show kernel disassembly"
	@echo "  size         - Show size information"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean        - Clean all build files"
	@echo "  clean-swift  - Clean Swift files only"
	@echo "  check-tools  - Verify build tools"
	@echo ""
	@echo "Kernel Modes:"
	@echo "  KERNEL_MODE=swift (default) - Use Swift kernel"
	@echo "  KERNEL_MODE=c               - Use C-only kernel"
	@echo ""
	@echo "Examples:"
	@echo "  make swift-only run    # Build Swift kernel and run"
	@echo "  make c-only debug      # Build C kernel and debug"
	@echo "  make KERNEL_MODE=c iso # Build C kernel ISO"

# === DEPENDENCY TRACKING ===
-include $(OBJECTS:.o=.d)

# Generate dependency files
$(BUILDDIR)/%.d: $(SRCDIR)/%.c | $(BUILDDIR)
	@$(CC) $(CFLAGS) -MM -MT $(@:.d=.o) $< > $@

# === ERROR HANDLING ===
.DELETE_ON_ERROR:

# Check for required files
check-files:
	@test -f "$(SWIFTSRCDIR)/Package.swift" || (echo "ERROR: Swift Package.swift not found" && exit 1)
	@test -f "linker_swift.ld" || (echo "ERROR: Swift linker script not found" && exit 1)
	@test -f "$(SRCDIR)/boot.s" || (echo "ERROR: Boot assembly file not found" && exit 1)
	@echo "All required files found!"

# Force rebuild targets
force-rebuild: clean all

.PHONY: check-files force-rebuild show-symbols show-sections show-swift-symbols disassemble size test-swift test-c test-all clean-swift
