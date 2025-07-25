# MAGIos Makefile - Swift-First Operating System
# Evangelion-themed OS kernel built with Embedded Swift
# macOS/Linux only - requires Swift development snapshot

# === TOOLCHAIN CONFIGURATION ===
ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld
SWIFT = swift

# === COMPILATION FLAGS ===
ASMFLAGS = -f elf32
CFLAGS = -m32 -ffreestanding -fno-stack-protector -fno-builtin -nostdlib -Wall -Wextra -std=c99
LDFLAGS = -m elf_i386 -T linker.ld

# Swift compilation flags for embedded target - simplified
SWIFTFLAGS = -enable-experimental-feature Embedded \
	-target i686-unknown-none-elf \
	-Xfrontend -disable-objc-interop \
	-Xclang-linker -nostdlib \
	-wmo \
	-c -emit-object

# === DIRECTORIES ===
SRCDIR = src
SWIFTSRCDIR = ./swift
BUILDDIR = build
ISODIR = iso

# === SOURCE FILES ===
ASM_SOURCES = $(wildcard $(SRCDIR)/*.s)
C_SOURCES = $(SRCDIR)/kernel.c
ASM_OBJECTS = $(ASM_SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)
C_OBJECTS = $(C_SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)

# Swift objects
SWIFT_LIB = .build/release/libMAGIosSwift.a
# All objects for final kernel
OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS)

# === PHONY TARGETS ===
.PHONY: all clean iso run debug check-tools help swift-check magi-status

# === DEFAULT TARGET ===
all: magi-status check-tools $(BUILDDIR)/kernel.bin

# === MAGI SYSTEM STATUS ===
magi-status:
	@echo ""
	@echo "========================================="
	@echo "MAGI SYSTEM STARTUP SEQUENCE INITIATED"
	@echo "========================================="
	@echo ""
	@echo "CASPER... CHECKING SWIFT TOOLCHAIN"
	@echo "MELCHIOR... VERIFYING CROSS-COMPILER"
	@echo "BALTHASAR... INITIALIZING BUILD SYSTEM"
	@echo ""

# === TOOL VERIFICATION ===
check-tools:
	@echo "Checking MAGI subsystems..."
	@which nasm > /dev/null || (echo "❌ CASPER ERROR: nasm not found" && echo "Install with: brew install nasm" && exit 1)
	@which qemu-system-i386 > /dev/null || (echo "❌ MELCHIOR ERROR: qemu not found" && echo "Install with: brew install qemu" && exit 1)
	@which i686-elf-gcc > /dev/null || (echo "❌ BALTHASAR ERROR: i686-elf-gcc not found" && echo "Install with: brew tap nativeos/i686-elf-toolchain && brew install i686-elf-gcc" && exit 1)
	@which swift > /dev/null || (echo "❌ SWIFT ERROR: swift not found" && echo "Install Swift development snapshot from swift.org" && exit 1)
	@echo "All MAGI subsystems operational ✅"
	@echo ""

# === BUILD DIRECTORY ===
$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

# === SWIFT COMPILATION ===
$(SWIFT_LIB): $(shell find $(SRCDIR)/swift/ -name "*.swift" 2>/dev/null)
	@echo "🔹 Compiling Swift kernel components..."
	@swiftc $(SWIFTFLAGS) $(SRCDIR)/swift/*.swift -o $(BUILDDIR)/swift_kernel.o
	@mkdir -p .build/release
	@ar rcs $@ $(BUILDDIR)/swift_kernel.o
	@echo "Swift library built: $@"



# === C COMPILATION ===
$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	@echo "🔹 Compiling C bridge: $<"
	$(CC) $(CFLAGS) -I$(SRCDIR)/swift/include -c $< -o $@

# === ASSEMBLY ===
$(BUILDDIR)/%.o: $(SRCDIR)/%.s | $(BUILDDIR)
	@echo "🔹 Assembling boot code: $<"
	$(ASM) $(ASMFLAGS) $< -o $@

# === KERNEL BINARY ===
$(BUILDDIR)/kernel.bin: $(OBJECTS) $(SWIFT_LIB)
	@echo ""
	@echo "🔗 Linking MAGIos Swift kernel..."
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS) --whole-archive $(SWIFT_LIB) --no-whole-archive
	@echo ""
	@echo "✅ MAGIos Swift kernel compiled successfully!"
	@echo "   Binary size: $$(ls -lh $@ | awk '{print $$5}')"
	@echo ""

# === SWIFT SYNTAX CHECK ===
swift-check:
	@echo "🔍 Checking Swift syntax..."
	@swift build --triple i686-unknown-none-elf -c release > /dev/null
	@echo "✅ Swift syntax check passed"

# === ISO CREATION ===
iso: $(BUILDDIR)/kernel.bin
	@echo "📀 Creating Terminal Dogma ISO..."
	@mkdir -p $(ISODIR)/boot/grub
	cp $(BUILDDIR)/kernel.bin $(ISODIR)/boot/
	cp grub.cfg $(ISODIR)/boot/grub/
	@if command -v grub-mkrescue >/dev/null 2>&1; then \
		grub-mkrescue -o magios.iso $(ISODIR) 2>/dev/null; \
	elif command -v i686-elf-grub-mkrescue >/dev/null 2>&1; then \
		i686-elf-grub-mkrescue -o magios.iso $(ISODIR) 2>/dev/null; \
	else \
		echo "⚠️ grub-mkrescue not found, trying xorriso..."; \
		xorriso -as mkisofs -R -b boot/grub/i386-pc/eltorito.img \
			-no-emul-boot -boot-load-size 4 -boot-info-table \
			-o magios.iso $(ISODIR) 2>/dev/null || \
		(echo "❌ ISO creation failed. Install grub with: brew install grub" && exit 1); \
	fi
	@echo "✅ ISO created: magios.iso ($$(ls -lh magios.iso | awk '{print $$5}'))"
	@echo ""
	@echo "🎌 Terminal Dogma is ready for deployment"

# === RUN IN QEMU ===
run: iso
	@echo "🚀 Launching MAGIos in QEMU..."
	@echo "   AT Field operational. Pattern Blue."
	@echo ""
	qemu-system-i386 -cdrom magios.iso

# === DEBUG MODE ===
debug: iso
	@echo "🐛 Launching MAGIos in debug mode..."
	@echo "   Connect GDB to localhost:1234"
	@echo ""
	qemu-system-i386 -cdrom magios.iso -s -S

# === TESTING ===
test: iso
	@echo "🧪 Testing MAGIos kernel..."
	timeout 10s qemu-system-i386 -cdrom magios.iso -nographic -serial stdio || true

# === DEVELOPMENT HELPERS ===
show-symbols: $(BUILDDIR)/kernel.bin
	@echo "📋 Kernel symbols:"
	@i686-elf-nm $(BUILDDIR)/kernel.bin | grep -E "(swift_|main|start)" | head -15

show-sections: $(BUILDDIR)/kernel.bin
	@echo "📋 Kernel sections:"
	@i686-elf-objdump -h $(BUILDDIR)/kernel.bin

size: $(BUILDDIR)/kernel.bin
	@echo "📊 Kernel size information:"
	@i686-elf-size $(BUILDDIR)/kernel.bin
	@echo ""
	@echo "File sizes:"
	@ls -lh $(BUILDDIR)/kernel.bin
	@if [ -f "magios.iso" ]; then ls -lh magios.iso; fi

disassemble: $(BUILDDIR)/kernel.bin
	@echo "🔍 Swift kernel disassembly (first 30 lines):"
	@i686-elf-objdump -d $(BUILDDIR)/kernel.bin | grep -A 30 "swift_kernel_main"

# === CLEANUP ===
clean:
	@echo "🧹 Cleaning Terminal Dogma..."
	rm -rf $(BUILDDIR) $(ISODIR) magios.iso
	@if [ -d ".build" ]; then \
		echo "🧹 Cleaning Swift build cache..."; \
		swift package clean; \
	fi
	@echo "✅ Clean completed"

# === HELP ===
help:
	@echo ""
	@echo "========================================="
	@echo "MAGIos Swift Kernel Build System"
	@echo "Evangelion-themed OS with Embedded Swift"
	@echo "========================================="
	@echo ""
	@echo "Main Targets:"
	@echo "  all          - Build Swift kernel (default)"
	@echo "  iso          - Create bootable ISO image"
	@echo "  run          - Build and run in QEMU"
	@echo "  debug        - Build and run with GDB support"
	@echo "  test         - Quick kernel test"
	@echo ""
	@echo "Development:"
	@echo "  swift-check  - Verify Swift syntax"
	@echo "  show-symbols - Display kernel symbols"
	@echo "  show-sections- Show binary sections"
	@echo "  disassemble  - Show Swift code disassembly"
	@echo "  size         - Display size information"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean        - Remove all build artifacts"
	@echo "  check-tools  - Verify toolchain installation"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - Swift development snapshot (6.0-dev)"
	@echo "  - Cross-compiler: brew install i686-elf-gcc"
	@echo "  - QEMU: brew install qemu"
	@echo "  - NASM: brew install nasm"
	@echo ""
	@echo "Terminal Dogma awaits your command... 🤖"

# === DEPENDENCY TRACKING ===
-include $(C_OBJECTS:.o=.d)

$(BUILDDIR)/%.d: $(SRCDIR)/%.c | $(BUILDDIR)
	@$(CC) $(CFLAGS) -MM -MT $(@:.d=.o) $< > $@

# === ERROR HANDLING ===
.DELETE_ON_ERROR:

# Force rebuild
rebuild: clean all

.PHONY: rebuild magi-status swift-check show-symbols show-sections size disassemble
