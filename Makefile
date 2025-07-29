# MAGIos Makefile - Swift-First Operating System
# Simplified build system using centralized configuration
# Evangelion-themed OS kernel built with Embedded Swift

# === TOOLCHAIN CONFIGURATION ===
export TOOLCHAINS=org.swift.62202505141a
ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld
SWIFT = swiftc

# === TARGET ARCHITECTURE ===
TARGET_ARCH = i686-unknown-none-elf
TARGET_BITS = 32

# === COMPILATION FLAGS ===
ASMFLAGS = -f elf32
CFLAGS = -m32 -ffreestanding -fno-stack-protector -fno-builtin -nostdlib -Wall -Wextra -std=c99
LDFLAGS = -m elf_i386 -T linker.ld
SWIFTFLAGS = -enable-experimental-feature Embedded -target $(TARGET_ARCH) -Xfrontend -disable-objc-interop -Xfrontend -function-sections -parse-stdlib -module-name SwiftKernel -wmo -c -emit-object

# === DIRECTORIES ===
# Centralized path configuration for easier maintenance
SRCDIR = src
KERNEL_SRCDIR = $(SRCDIR)/kernel
SWERNEL_SRCDIR = $(SRCDIR)/swernel
SUPPORT_SRCDIR = $(SRCDIR)/support
BUILDDIR = build
ISODIR = iso

# Legacy compatibility (updating gradually to swernel)
SWIFT_SRCDIR = $(SWERNEL_SRCDIR)

# === QEMU CONFIGURATION ===
QEMU_SYSTEM = qemu-system-i386
QEMU_FLAGS = -cdrom $(ISO_FILE)
QEMU_DEBUG_FLAGS = -s -S

# === BUILD TARGETS ===
KERNEL_BINARY = $(BUILDDIR)/kernel.bin
ISO_FILE = magios.iso

# === MAGI SYSTEM NAMES ===
MAGI_CASPER = CASPER
MAGI_MELCHIOR = MELCHIOR
MAGI_BALTHASAR = BALTHASAR

# === VERSION INFO ===
MAGIOS_VERSION = 0.0.1
MAGIOS_CODENAME = Terminal Dogma

# === BUILD OUTPUT STYLING ===
SILENT_CHECKS = true
SHOW_PROGRESS = true
USE_MAGI_THEMING = true

# === SOURCE FILES ===
# Using centralized path variables for easier maintenance
ASM_SOURCES = $(wildcard $(SRCDIR)/*.s)
C_SOURCES = $(wildcard $(KERNEL_SRCDIR)/*.c)
SWIFT_SOURCES = $(wildcard $(SWERNEL_SRCDIR)/*.swift)

ASM_OBJECTS = $(ASM_SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)
C_OBJECTS = $(C_SOURCES:$(KERNEL_SRCDIR)/%.c=$(BUILDDIR)/%.o)
SWIFT_OBJECT = $(BUILDDIR)/swift_kernel.o

ALL_OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS) $(SWIFT_OBJECT)

# === PHONY TARGETS ===
.PHONY: all clean iso run debug check-tools help swift-check magi-status test

# === DEFAULT TARGET ===
all: magi-status $(KERNEL_BINARY)

# === MAGI SYSTEM STATUS ===
magi-status:
ifeq ($(USE_MAGI_THEMING),true)
	@echo "$(MAGI_CASPER)... Initializing"
	@echo "$(MAGI_MELCHIOR)... Standby"
	@echo "$(MAGI_BALTHASAR)... Ready"
	@echo ""
endif

# === TOOL VERIFICATION ===
check-tools:
	@echo "Verifying MAGI subsystems..."
	@for tool in nasm qemu-system-i386 i686-elf-gcc swiftc; do \
		command -v $$tool >/dev/null 2>&1 || { \
			echo "❌ $$tool not found"; \
			echo "Run ./build.sh to install dependencies"; \
			exit 1; \
		}; \
	done
ifeq ($(SILENT_CHECKS),true)
	@echo "✅ All tools operational"
else
	@echo "✅ $(MAGI_CASPER): nasm operational"
	@echo "✅ $(MAGI_MELCHIOR): Swift operational"
	@echo "✅ $(MAGI_BALTHASAR): Cross-compiler operational"
	@echo "✅ QEMU operational"
endif
	@echo ""

# === BUILD DIRECTORY ===
$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

# === SWIFT COMPILATION ===
$(SWIFT_OBJECT): $(SWIFT_SOURCES) | $(BUILDDIR)
ifeq ($(SHOW_PROGRESS),true)
	@echo "🔹 Compiling Swift kernel components..."
endif
	@swiftc $(SWIFTFLAGS) $(SWIFT_SOURCES) -o $@

# === C COMPILATION ===
$(BUILDDIR)/%.o: $(KERNEL_SRCDIR)/%.c | $(BUILDDIR)
ifeq ($(SHOW_PROGRESS),true)
	@echo "🔹 Compiling C bridge: $<"
endif
	@$(CC) $(CFLAGS) -I$(KERNEL_SRCDIR) -c $< -o $@

# === ASSEMBLY ===
$(BUILDDIR)/%.o: $(SRCDIR)/%.s | $(BUILDDIR)
ifeq ($(SHOW_PROGRESS),true)
	@echo "🔹 Assembling boot code: $<"
endif
	@$(ASM) $(ASMFLAGS) $< -o $@

# === KERNEL BINARY ===
$(KERNEL_BINARY): $(ALL_OBJECTS)
ifeq ($(SHOW_PROGRESS),true)
	@echo ""
	@echo "🔗 Linking MAGIos Swift kernel..."
endif
	@$(LD) $(LDFLAGS) -o $@ $(ALL_OBJECTS)
ifeq ($(SHOW_PROGRESS),true)
	@echo "   Binary size: $$(ls -lh $@ | awk '{print $$5}')"
endif

# === SWIFT SYNTAX CHECK ===
swift-check:
	@echo "🔍 Checking Swift syntax..."
	@swiftc -typecheck $(SWIFT_SOURCES) \
		-enable-experimental-feature Embedded \
		-target $(TARGET_ARCH) \
		-parse-stdlib
	@echo "✅ Swift syntax check passed"

# === ISO CREATION ===
iso: $(KERNEL_BINARY)
ifeq ($(SHOW_PROGRESS),true)
	@echo "📀 Creating Terminal Dogma ISO..."
endif
	@mkdir -p $(ISODIR)/boot/grub
	@cp $(KERNEL_BINARY) $(ISODIR)/boot/
	@cp grub.cfg $(ISODIR)/boot/grub/
	@if command -v i686-elf-grub-mkrescue >/dev/null 2>&1; then \
		i686-elf-grub-mkrescue -o $(ISO_FILE) $(ISODIR) 2>/dev/null; \
	elif command -v grub-mkrescue >/dev/null 2>&1; then \
		grub-mkrescue -o $(ISO_FILE) $(ISODIR) 2>/dev/null; \
	else \
		echo "❌ grub-mkrescue not found. Install with: brew install i686-elf-grub"; \
		exit 1; \
	fi
ifeq ($(SHOW_PROGRESS),true)
	@echo "✅ ISO created: $(ISO_FILE) ($$(ls -lh $(ISO_FILE) | awk '{print $$5}'))"
endif

# === RUN IN QEMU ===
run: iso
ifeq ($(USE_MAGI_THEMING),true)
	@echo "🚀 Launching MAGIos in QEMU..."
	@echo "   AT Field operational. Pattern Blue."
	@echo ""
endif
	@$(QEMU_SYSTEM) $(QEMU_FLAGS)

# === DEBUG MODE ===
debug: iso
	@echo "🐛 Launching MAGIos in debug mode..."
	@echo "   Connect GDB to localhost:1234"
	@echo ""
	@$(QEMU_SYSTEM) $(QEMU_FLAGS) $(QEMU_DEBUG_FLAGS)

# === TESTING ===
test: iso
	@echo "🧪 Testing MAGIos kernel..."
	@timeout 10s $(QEMU_SYSTEM) $(QEMU_FLAGS) -nographic -serial stdio || true

# === DEVELOPMENT HELPERS ===
show-symbols: $(KERNEL_BINARY)
	@echo "📋 Kernel symbols:"
	@i686-elf-nm $(KERNEL_BINARY) | grep -E "(swift_|main|start)" | head -15

size: $(KERNEL_BINARY)
	@echo "📊 Kernel size information:"
	@i686-elf-size $(KERNEL_BINARY)
	@echo ""
	@echo "File sizes:"
	@ls -lh $(KERNEL_BINARY)
	@if [ -f "$(ISO_FILE)" ]; then ls -lh $(ISO_FILE); fi

# === CLEANUP ===
clean:
ifeq ($(SHOW_PROGRESS),true)
	@echo "🧹 Cleaning Terminal Dogma..."
endif
	@rm -rf $(BUILDDIR) $(ISODIR) $(ISO_FILE)
ifeq ($(SHOW_PROGRESS),true)
	@echo "✅ Clean completed"
endif

# === HELP ===
help:
	@echo ""
	@echo "========================================="
	@echo "MAGIos $(MAGIOS_VERSION) - $(MAGIOS_CODENAME)"
	@echo "Swift-First Operating System"
	@echo "========================================="
	@echo ""
	@echo "Build Commands:"
	@echo "  all          - Build Swift kernel (default)"
	@echo "  iso          - Create bootable ISO"
	@echo "  run          - Build and launch in QEMU"
	@echo "  debug        - Launch with GDB debugging"
	@echo "  test         - Quick kernel test"
	@echo ""
	@echo "Development:"
	@echo "  swift-check  - Verify Swift syntax"
	@echo "  show-symbols - Display kernel symbols"
	@echo "  size         - Show binary size info"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean        - Remove build artifacts"
	@echo "  check-tools  - Verify toolchain"
	@echo ""
	@echo "Quick Start:"
	@echo "  ./build.sh --run    # Build and run"
	@echo ""
	@echo "Variables (from build.config):"
	@echo "  Target: $(TARGET_ARCH)"
	@echo "  Swift: $(SWIFTFLAGS)"
	@echo "  C: $(CFLAGS)"
	@echo ""
ifeq ($(USE_MAGI_THEMING),true)
	@echo "Terminal Dogma awaits your command... 🤖"
endif

# === ERROR HANDLING ===
.DELETE_ON_ERROR:

# Force rebuild
rebuild: clean all

.PHONY: rebuild show-symbols size
