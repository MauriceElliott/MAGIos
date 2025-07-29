# MAGIos Makefile - Swift-First Operating System
# See MAKEFILE_DOCUMENTATION at bottom for detailed documentation

export TOOLCHAINS=org.swift.62202505141a
ASM = nasm
CC = i686-elf-gcc
LD = i686-elf-ld
SWIFT = swiftc

TARGET_ARCH = i686-unknown-none-elf
TARGET_BITS = 32

# COMPILATION_FLAGS
ASMFLAGS = -f elf32
CFLAGS = -m32 -ffreestanding -fno-stack-protector -fno-builtin -nostdlib -Wall -Wextra -std=c99
LDFLAGS = -m elf_i386 -T linker.ld
SWIFTFLAGS = -enable-experimental-feature Embedded -target $(TARGET_ARCH) -Xfrontend -disable-objc-interop -Xfrontend -function-sections -parse-stdlib -module-name SwiftKernel -wmo -c -emit-object

# DIRECTORY_PATHS
SRCDIR = src
KERNEL_SRCDIR = $(SRCDIR)/kernel
SWERNEL_SRCDIR = $(SRCDIR)/swernel
SUPPORT_SRCDIR = $(SRCDIR)/support
BUILDDIR = build
ISODIR = iso
SWIFT_SRCDIR = $(SWERNEL_SRCDIR)

# QEMU_CONFIG
QEMU_SYSTEM = qemu-system-i386
QEMU_FLAGS = -cdrom $(ISO_FILE)
QEMU_DEBUG_FLAGS = -s -S

# BUILD_TARGETS
KERNEL_BINARY = $(BUILDDIR)/kernel.bin
ISO_FILE = magios.iso

# MAGI_SYSTEM_NAMES
MAGI_CASPER = CASPER
MAGI_MELCHIOR = MELCHIOR
MAGI_BALTHASAR = BALTHASAR

# VERSION_INFO
MAGIOS_VERSION = 0.0.1
MAGIOS_CODENAME = Terminal Dogma

# BUILD_STYLING
SILENT_CHECKS = true
SHOW_PROGRESS = true
USE_MAGI_THEMING = true

# SOURCE_FILES
ASM_SOURCES = $(wildcard $(SRCDIR)/*.s)
C_SOURCES = $(wildcard $(KERNEL_SRCDIR)/*.c)
SWIFT_SOURCES = $(wildcard $(SWERNEL_SRCDIR)/*.swift)

ASM_OBJECTS = $(ASM_SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)
C_OBJECTS = $(C_SOURCES:$(KERNEL_SRCDIR)/%.c=$(BUILDDIR)/%.o)
SWIFT_OBJECT = $(BUILDDIR)/swift_kernel.o

ALL_OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS) $(SWIFT_OBJECT)

.PHONY: all clean iso run debug check-tools help swift-check magi-status test

all: magi-status $(KERNEL_BINARY)

# MAGI_STATUS_DISPLAY
magi-status:
ifeq ($(USE_MAGI_THEMING),true)
	@echo "$(MAGI_CASPER)... Initializing"
	@echo "$(MAGI_MELCHIOR)... Standby"
	@echo "$(MAGI_BALTHASAR)... Ready"
	@echo ""
endif

# TOOL_VERIFICATION
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

$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

# SWIFT_COMPILATION
$(SWIFT_OBJECT): $(SWIFT_SOURCES) | $(BUILDDIR)
ifeq ($(SHOW_PROGRESS),true)
	@echo "🔹 Compiling Swift kernel components..."
endif
	@swiftc $(SWIFTFLAGS) $(SWIFT_SOURCES) -o $@

# C_COMPILATION
$(BUILDDIR)/%.o: $(KERNEL_SRCDIR)/%.c | $(BUILDDIR)
ifeq ($(SHOW_PROGRESS),true)
	@echo "🔹 Compiling C bridge: $<"
endif
	@$(CC) $(CFLAGS) -I$(KERNEL_SRCDIR) -c $< -o $@

# ASSEMBLY_COMPILATION
$(BUILDDIR)/%.o: $(SRCDIR)/%.s | $(BUILDDIR)
ifeq ($(SHOW_PROGRESS),true)
	@echo "🔹 Assembling boot code: $<"
endif
	@$(ASM) $(ASMFLAGS) $< -o $@

# KERNEL_LINKING
$(KERNEL_BINARY): $(ALL_OBJECTS)
ifeq ($(SHOW_PROGRESS),true)
	@echo ""
	@echo "🔗 Linking MAGIos Swift kernel..."
endif
	@$(LD) $(LDFLAGS) -o $@ $(ALL_OBJECTS)
ifeq ($(SHOW_PROGRESS),true)
	@echo "   Binary size: $$(ls -lh $@ | awk '{print $$5}')"
endif

# SWIFT_SYNTAX_CHECK
swift-check:
	@echo "🔍 Checking Swift syntax..."
	@swiftc -typecheck $(SWIFT_SOURCES) \
		-enable-experimental-feature Embedded \
		-target $(TARGET_ARCH) \
		-parse-stdlib
	@echo "✅ Swift syntax check passed"

# ISO_CREATION
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

# QEMU_RUN
run: iso
ifeq ($(USE_MAGI_THEMING),true)
	@echo "🚀 Launching MAGIos in QEMU..."
	@echo "   AT Field operational. Pattern Blue."
	@echo ""
endif
	@$(QEMU_SYSTEM) $(QEMU_FLAGS)

# DEBUG_MODE
debug: iso
	@echo "🐛 Launching MAGIos in debug mode..."
	@echo "   Connect GDB to localhost:1234"
	@echo ""
	@$(QEMU_SYSTEM) $(QEMU_FLAGS) $(QEMU_DEBUG_FLAGS)

# TESTING
test: iso
	@echo "🧪 Testing MAGIos kernel..."
	@timeout 10s $(QEMU_SYSTEM) $(QEMU_FLAGS) -nographic -serial stdio || true

# DEVELOPMENT_HELPERS
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

# CLEANUP
clean:
ifeq ($(SHOW_PROGRESS),true)
	@echo "🧹 Cleaning Terminal Dogma..."
endif
	@rm -rf $(BUILDDIR) $(ISODIR) $(ISO_FILE)
ifeq ($(SHOW_PROGRESS),true)
	@echo "✅ Clean completed"
endif

# HELP_DISPLAY
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

.DELETE_ON_ERROR:

rebuild: clean all

.PHONY: rebuild show-symbols size

#
# === MAKEFILE_DOCUMENTATION ===
#
# TOOLCHAIN_CONFIGURATION:
# export TOOLCHAINS=org.swift.62202505141a - Specific Swift toolchain version
# Target architecture and compilation settings for embedded Swift kernel
#
# COMPILATION_FLAGS:
# ASMFLAGS: Assembler flags for 32-bit ELF output
# CFLAGS: C compiler flags for freestanding kernel environment
# LDFLAGS: Linker flags using custom linker script
# SWIFTFLAGS: Swift compiler flags for embedded mode
#
# DIRECTORY_PATHS:
# Centralized path configuration for easier maintenance
# KERNEL_SRCDIR: C kernel source location
# SWERNEL_SRCDIR: Swift kernel (swernel) source location
# SUPPORT_SRCDIR: Support library location
#
# MAGI_SYSTEM_NAMES:
# Evangelion-themed component names for build output
# CASPER: Character display subsystem
# MELCHIOR: Memory management
# BALTHASAR: Boot coordination
#
# BUILD_STYLING:
# Control verbosity and theming of build output
#
# SOURCE_FILES:
# Wildcard patterns to find all source files in their respective directories
# Pattern substitution to generate object file lists
#
# MAGI_STATUS_DISPLAY:
# Evangelion-themed startup sequence display
#
# TOOL_VERIFICATION:
# Checks for required build tools before compilation
#
# SWIFT_COMPILATION:
# Compiles Swift kernel components with embedded flags
#
# C_COMPILATION:
# Compiles C kernel bridge with include path configuration
#
# ASSEMBLY_COMPILATION:
# Assembles bootloader code
#
# KERNEL_LINKING:
# Links all object files into final kernel binary
#
# SWIFT_SYNTAX_CHECK:
# Validates Swift syntax without generating output
#
# ISO_CREATION:
# Creates bootable ISO with GRUB bootloader
#
# QEMU_RUN:
# Launches kernel in QEMU emulator
#
# DEBUG_MODE:
# Launches kernel with GDB debugging support
#
# TESTING:
# Quick automated test run
#
# DEVELOPMENT_HELPERS:
# show-symbols: Display kernel symbol table
# size: Show binary size information
#
# CLEANUP:
# Removes all build artifacts
#
# HELP_DISPLAY:
# Shows available commands and usage information
