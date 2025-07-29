/*
 * MAGIos Kernel Bridge Header
 * See KERNEL_BRIDGE_DOCUMENTATION at bottom for detailed documentation
 */

#ifndef KERNEL_BRIDGE_H
#define KERNEL_BRIDGE_H

#define KERNEL_BRIDGE_PATH "src/kernel/include/kernel_bridge.h"
#define SWIFT_KERNEL_PATH "src/swernel/swernel.swift"
#define C_KERNEL_PATH "src/kernel/kernel.c"
#define BOOT_ASM_PATH "src/boot.s"
#define LINKER_SCRIPT_PATH "src/linker.ld"
#define GRUB_CONFIG_PATH "src/grub.cfg"
#define SUPPORT_CSTDLIB_PATH "src/support/cstdlib/"
#define SUPPORT_SWTDLIB_PATH "src/support/swtdlib/"

#include <stddef.h>
#include <stdint.h>

// MAGI_MEMORY_FUNCTIONS
void *malloc(size_t size);
void free(void *ptr);
void *memcpy(void *dest, const void *src, size_t n);
void *memset(void *s, int c, size_t n);
void *memmove(void *dest, const void *src, size_t n);

// MAGI_DIAGNOSTICS
size_t magi_heap_available(void);
int magi_heap_check(void);

// MAGI_BOOT_FUNCTIONS
void magi_boot_message(void);

// SWIFT_KERNEL_FUNCTIONS
void swift_kernel_main(void);
void swift_terminal_writestring(const char *data);
void swift_terminal_setcolor(uint8_t color);
void swift_terminal_initialize(void);

// SHARED_CONSTANTS
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY 0xB8000

// VGA_COLOR_ENUM
typedef enum {
  VGA_COLOR_BLACK = 0,
  VGA_COLOR_BLUE = 1,
  VGA_COLOR_GREEN = 2,
  VGA_COLOR_CYAN = 3,
  VGA_COLOR_RED = 4,
  VGA_COLOR_MAGENTA = 5,
  VGA_COLOR_BROWN = 6,
  VGA_COLOR_LIGHT_GREY = 7,
  VGA_COLOR_DARK_GREY = 8,
  VGA_COLOR_LIGHT_BLUE = 9,
  VGA_COLOR_LIGHT_GREEN = 10,
  VGA_COLOR_LIGHT_CYAN = 11,
  VGA_COLOR_LIGHT_RED = 12,
  VGA_COLOR_LIGHT_MAGENTA = 13,
  VGA_COLOR_LIGHT_BROWN = 14,
  VGA_COLOR_WHITE = 15,
} vga_color_t;

// COLOR_HELPER_MACROS
#define VGA_ENTRY_COLOR(fg, bg) ((fg) | ((bg) << 4))
#define VGA_ENTRY(uc, color) ((uint16_t)(uc) | ((uint16_t)(color) << 8))

// KERNEL_INTEGRATION_MODES
#ifndef KERNEL_MODE
#define KERNEL_MODE_C_ONLY 0
#define KERNEL_MODE_MIXED 1
#define KERNEL_MODE_SWIFT_ONLY 2
#define KERNEL_MODE KERNEL_MODE_MIXED
#endif

// MEMORY_LAYOUT
#define KERNEL_BASE_ADDR 0x00100000
#define KERNEL_STACK_SIZE 16384

// BOOT_INFO_STRUCT
typedef struct {
  uint32_t magic;
  uint32_t flags;
  uint32_t memory_lower;
  uint32_t memory_upper;
} boot_info_t;

void swift_kernel_init(const boot_info_t *boot_info);

#endif /* KERNEL_BRIDGE_H */

/*
 * === KERNEL_BRIDGE_DOCUMENTATION ===
 *
 * PROJECT_STRUCTURE:
 * Current MAGIos directory layout:
 * src/
 * ├── boot.s                    # x86 assembly bootloader
 * ├── grub.cfg                  # GRUB bootloader configuration
 * ├── linker.ld                 # Memory layout specification
 * ├── kernel/
 * │   ├── kernel.c              # C bootstrap & hardware init
 * │   └── include/
 * │       └── kernel_bridge.h   # This file - C/Swift interoperability
 * ├── swernel/
 * │   └── swernel.swift         # Swift kernel (MAGI system core)
 * └── support/
 *     ├── cstdlib/              # C standard library extensions
 *     └── swtdlib/              # Swift standard library extensions
 *
 * SWIFT_KERNEL_FUNCTIONS:
 * These functions are implemented in Swift but callable from C
 * They are exported using @_cdecl attribute in the Swift code
 *
 * swift_kernel_main: Main Swift kernel entry point
 * This function replaces the C kernel_main functionality
 * Call this after basic system initialization is complete
 *
 * swift_terminal_writestring: Swift implementation of terminal string output
 * @param data: Null-terminated string to display
 *
 * swift_terminal_setcolor: Swift implementation of terminal color change
 * @param color: VGA color byte (foreground | background << 4)
 *
 * swift_terminal_initialize: Swift implementation of terminal initialization
 * Sets up VGA text mode and clears the screen
 *
 * SHARED_CONSTANTS:
 * These constants are used by both C and Swift code
 * They must match the definitions in the Swift implementation
 *
 * VGA_COLOR_ENUM:
 * VGA Color constants for C code compatibility
 *
 * COLOR_HELPER_MACROS:
 * Helper macros for color creation
 *
 * KERNEL_INTEGRATION_MODES:
 * Define which kernel implementation to use
 * This allows gradual migration from C to Swift
 *
 * MEMORY_LAYOUT:
 * Shared memory layout definitions for both C and Swift
 * Kernel memory layout - must match linker script
 *
 * BOOT_INFO_STRUCT:
 * Structures for passing boot information between C and Swift
 *
 * USAGE_NOTES:
 *
 * From C code:
 *   #include "kernel_bridge.h"
 *   swift_kernel_main();  // Call Swift kernel
 *
 * From Swift code:
 *   // Functions are automatically available via @_cdecl
 *   // No additional imports needed
 *
 * INTEGRATION_STRATEGY:
 * 1. Phase 1: Keep existing C kernel, add Swift functions
 * 2. Phase 2: Gradually replace C functions with Swift equivalents
 * 3. Phase 3: Full Swift kernel with minimal C bootstrap
 *
 * MAGI_MEMORY_FUNCTIONS:
 * Memory management functions implemented in memory_functions.c
 * These provide full malloc/free functionality with MAGI heap management
 * Available to both C and Swift code for dynamic memory allocation
 *
 * MAGI_DIAGNOSTICS:
 * Memory diagnostic functions for monitoring heap health
 * magi_heap_available: Returns available heap space
 * magi_heap_check: Verifies heap integrity (AT Field status)
 *
 * FUTURE_EXPANSION:
 * Reserved function declarations for future features:
 * - Interrupt handling (future)
 * - Process management (future)
 */
