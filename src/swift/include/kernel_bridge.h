/*
 * MAGIos Kernel Bridge Header
 * This header provides C declarations for Swift functions and shared types
 * It enables interoperability between the C boot code and Swift kernel
 */

#ifndef KERNEL_BRIDGE_H
#define KERNEL_BRIDGE_H

#include <stddef.h>
#include <stdint.h>

/* === SWIFT KERNEL FUNCTIONS ===
 * These functions are implemented in Swift but callable from C
 * They are exported using @_cdecl attribute in the Swift code
 */

/**
 * Main Swift kernel entry point
 * This function replaces the C kernel_main functionality
 * Call this after basic system initialization is complete
 */
void swift_kernel_main(void);

/**
 * Swift implementation of terminal string output
 * @param data: Null-terminated string to display
 */
void swift_terminal_writestring(const char *data);

/**
 * Swift implementation of terminal color change
 * @param color: VGA color byte (foreground | background << 4)
 */
void swift_terminal_setcolor(uint8_t color);

/**
 * Swift implementation of terminal initialization
 * Sets up VGA text mode and clears the screen
 */
void swift_terminal_initialize(void);

/* === SHARED CONSTANTS ===
 * These constants are used by both C and Swift code
 * They must match the definitions in the Swift implementation
 */

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY 0xB8000

/* VGA Color constants for C code compatibility */
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

/* Helper macros for color creation */
#define VGA_ENTRY_COLOR(fg, bg) ((fg) | ((bg) << 4))
#define VGA_ENTRY(uc, color) ((uint16_t)(uc) | ((uint16_t)(color) << 8))

/* === C KERNEL FUNCTIONS ===
 * These functions are implemented in C and may be called from Swift
 * (Currently none, but this section is reserved for future expansion)
 */

/* === KERNEL INTEGRATION MODES ===
 * Define which kernel implementation to use
 * This allows gradual migration from C to Swift
 */

#ifndef KERNEL_MODE
#define KERNEL_MODE_C_ONLY 0
#define KERNEL_MODE_MIXED 1
#define KERNEL_MODE_SWIFT_ONLY 2
#define KERNEL_MODE KERNEL_MODE_MIXED /* Default to mixed mode */
#endif

/* === MEMORY MANAGEMENT ===
 * Shared memory layout definitions for both C and Swift
 */

/* Kernel memory layout - must match linker script */
#define KERNEL_BASE_ADDR 0x00100000 /* 1MB - where kernel is loaded */
#define KERNEL_STACK_SIZE 16384     /* 16KB stack size */

/* === DEBUGGING AND DIAGNOSTICS ===
 * Functions for development and debugging
 */

#ifdef DEBUG
/**
 * Debug output function (if needed)
 */
void debug_print(const char *message);
#endif

/* === BOOT INFORMATION ===
 * Structures for passing boot information between C and Swift
 */

typedef struct {
  uint32_t magic;        /* Multiboot magic number */
  uint32_t flags;        /* Boot flags */
  uint32_t memory_lower; /* Lower memory size */
  uint32_t memory_upper; /* Upper memory size */
} boot_info_t;

/**
 * Initialize kernel with boot information
 * @param boot_info: Pointer to boot information structure
 */
void swift_kernel_init(const boot_info_t *boot_info);

/* === FUTURE EXPANSION ===
 * Reserved function declarations for future features
 */

/* Interrupt handling (future) */
/* void swift_interrupt_handler(uint32_t interrupt_number); */

/* Memory management (future) */
/* void* swift_kmalloc(size_t size); */
/* void swift_kfree(void *ptr); */

/* Process management (future) */
/* int swift_create_process(const char *name); */

#endif /* KERNEL_BRIDGE_H */

/*
 * USAGE NOTES:
 *
 * From C code:
 *   #include "kernel_bridge.h"
 *   swift_kernel_main();  // Call Swift kernel
 *
 * From Swift code:
 *   // Functions are automatically available via @_cdecl
 *   // No additional imports needed
 *
 * INTEGRATION STRATEGY:
 * 1. Phase 1: Keep existing C kernel, add Swift functions
 * 2. Phase 2: Gradually replace C functions with Swift equivalents
 * 3. Phase 3: Full Swift kernel with minimal C bootstrap
 */
