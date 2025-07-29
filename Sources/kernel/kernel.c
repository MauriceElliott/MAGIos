/*
 * MAGIos Kernel - Swift Integration Version
 * MAGI System Booting... Pattern Blue Detected
 * See KERNEL_ARCHITECTURE_NOTES at bottom for detailed documentation
 */

#define KERNEL_BRIDGE_HEADER "include/kernel_bridge.h"
#define SWIFT_KERNEL_DIR "../swernel/"

#include <stddef.h>
#include <stdint.h>
#include KERNEL_BRIDGE_HEADER
#include "../support/cstdlib/memory_functions.h"

// Forward declarations
void terminal_putchar(char c);
void terminal_setcolor(uint8_t color);
void terminal_writestring(const char *data);

// SWIFT_RUNTIME_STUBS
// Note: malloc and free now implemented in memory_functions.c

int posix_memalign(void **memptr, size_t alignment, size_t size) {
  (void)memptr;
  (void)alignment;
  (void)size;
  return -1; // POSIX_MEMALIGN_ERROR - Use MAGI malloc instead
}

void arc4random_buf(void *buf, size_t nbytes) { // ARC4_RANDOM_STUB
  unsigned char *p = (unsigned char *)buf;
  for (size_t i = 0; i < nbytes; i++) {
    p[i] = (unsigned char)(i * 0x5A + 0x3C);
  }
}

// MULTIBOOT_INFO_STRUCT
typedef struct multiboot_info {
  uint32_t flags;
  uint32_t mem_lower;
  uint32_t mem_upper;
  uint32_t boot_device;
  uint32_t cmdline;
  uint32_t mods_count;
  uint32_t mods_addr;
} multiboot_info_t;

// MAGI_BOOT_SEQUENCE
void magi_boot_message(void) {
  terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_CYAN, VGA_COLOR_BLACK));
  terminal_writestring("MAGI SYSTEM INITIALIZATION\n");
  terminal_writestring("==============================\n\n");

  terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));
  terminal_writestring("CASPER: Online... Pattern Blue Detected\n");
  terminal_writestring("MELCHIOR: Online... AT Field Nominal\n");
  terminal_writestring("BALTHASAR: Online... Synchronization Rate: 100%\n\n");

  terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_BROWN, VGA_COLOR_BLACK));
  terminal_writestring("NERV OS Version 3.33 - You Can (Not) Redo\n");
  terminal_writestring("All systems nominal. Angels detected: 0\n\n");

  terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
  terminal_writestring("Initializing Evangelion Unit-01...\n");
  terminal_writestring("Pilot: Shinji Ikari\n");
  terminal_writestring("Entry Plug insertion confirmed.\n\n");

  terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK));
  terminal_writestring("WARNING: Do not run away, Shinji!\n\n");

  terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK));
}

// EMERGENCY_FALLBACK
static void emergency_print(const char *message) {
  volatile uint16_t *vga_buffer = (uint16_t *)VGA_MEMORY;
  uint8_t color = VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK);

  for (int i = 0; i < VGA_WIDTH; i++) {
    vga_buffer[i] = VGA_ENTRY(' ', color);
  }

  int pos = 0;
  while (message[pos] && pos < VGA_WIDTH - 1) {
    vga_buffer[pos] = VGA_ENTRY(message[pos], color);
    pos++;
  }
}

// KERNEL_PANIC_HANDLER
static void kernel_panic(const char *message) {
  __asm__ volatile("cli");
  emergency_print("KERNEL PANIC: ");
  emergency_print(message);
  while (1) {
    __asm__ volatile("hlt");
  }
}

// TERMINAL_STATE
static volatile uint16_t *vga_buffer = (uint16_t *)VGA_MEMORY;
static size_t terminal_row = 0;
static size_t terminal_column = 0;
static uint8_t terminal_color =
    VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);

void terminal_setcolor(uint8_t color) { terminal_color = color; }

// STACK_PROTECTION
void *__stack_chk_guard = (void *)0xdeadbeef;

void __stack_chk_fail(void) {
  emergency_print("STACK OVERFLOW DETECTED");
  while (1) {
    __asm__ volatile("hlt");
  }
}

// STDLIB_FUNCTIONS
int putchar(int c) {
  terminal_putchar((char)c);
  return c;
}

// Note: memmove now implemented in memory_functions.c

void terminal_putchar(char c) {
  if (c == '\n') {
    terminal_column = 0;
    terminal_row++;
    if (terminal_row >= VGA_HEIGHT) {
      terminal_row = 0;
    }
    return;
  }

  const size_t index = terminal_row * VGA_WIDTH + terminal_column;
  vga_buffer[index] = VGA_ENTRY(c, terminal_color);

  terminal_column++;
  if (terminal_column >= VGA_WIDTH) {
    terminal_column = 0;
    terminal_row++;
    if (terminal_row >= VGA_HEIGHT) {
      terminal_row = 0;
    }
  }
}

void terminal_writestring(const char *data) {
  for (size_t i = 0; data[i] != 0; i++) {
    terminal_putchar(data[i]);
  }
}

// SWIFT_KERNEL_INIT
static void initialize_swernel(void) {
  __asm__ volatile("" ::: "memory");
  swift_kernel_main();
  __asm__ volatile("" ::: "memory");
}

// BOOT_INFO_PROCESSING
static boot_info_t process_multiboot_info(uint32_t magic,
                                          multiboot_info_t *mbi) {
  boot_info_t boot_info = {0};
  boot_info.magic = magic;

  if (mbi && (magic == 0x2BADB002)) {
    boot_info.flags = mbi->flags;
    if (mbi->flags & 0x01) {
      boot_info.memory_lower = mbi->mem_lower;
      boot_info.memory_upper = mbi->mem_upper;
    }
  }

  return boot_info;
}

// MAIN_KERNEL_ENTRY
void kernel_main(void) {
  __asm__ volatile("" ::: "memory");

  // Initialize Swift kernel (Swift will handle MAGI boot sequence)
  initialize_swernel();

  // Display final system status
  terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_GREEN, VGA_COLOR_BLACK));
  terminal_writestring("MAGI System fully operational.\n");
  terminal_writestring("Awaiting Angel attack patterns...\n");

  __asm__ volatile("cli");

  while (1) {
    __asm__ volatile("hlt"); // INFINITE_HALT_LOOP
  }
}

/*
 * === KERNEL_ARCHITECTURE_NOTES ===
 *
 * MAGI_BOOT_SEQUENCE:
 * Displays Evangelion-inspired boot messages referencing the MAGI system
 * (CASPER, MELCHIOR, BALTHASAR) and Evangelion Unit-01. Provides thematic
 * continuity and establishes the Neon Genesis Evangelion aesthetic.
 *
 * SWIFT_RUNTIME_STUBS:
 * Minimal implementations of standard library functions required by Swift
 * runtime. Memory functions (malloc, free, memcpy, memset, memmove) are now
 * implemented in memory_functions.c with full MAGI heap management.
 *
 * POSIX_MEMALIGN_ERROR:
 * Minimal memory allocation - directs users to use MAGI malloc instead.
 * Return error to force Swift to use MAGI memory management.
 *
 * ARC4_RANDOM_STUB:
 * Provide deterministic "random" data for embedded environment.
 * In a real kernel, this would use a proper PRNG.
 *
 * MULTIBOOT_INFO_STRUCT:
 * CRITICAL: Process multiboot information from GRUB.
 * This data is passed from the bootloader and contains system information.
 *
 * LEGACY_VGA_HELPERS:
 * These remain in C for compatibility and low-level operations.
 * Some may be gradually moved to Swift in future phases.
 *
 * EMERGENCY_FALLBACK:
 * These provide basic output if Swift kernel fails.
 * CRITICAL: These ensure we can always display error messages.
 *
 * KERNEL_PANIC_HANDLER:
 * CRITICAL: Handle kernel panic situations.
 * Disable interrupts to prevent further issues.
 *
 * TERMINAL_STATE:
 * These functions provide VGA terminal access to Swift kernel.
 *
 * STACK_PROTECTION:
 * Stack protection stubs for Swift runtime.
 * Stack overflow detected - halt the system.
 *
 * STDLIB_FUNCTIONS:
 * Standard C library functions required by Swift.
 *
 * CHARACTER_CONSTANTS_FOR_SWIFT:
 * These functions provide character constants that Swift can call
 * without needing to use integer literals (which don't work in -parse-stdlib
 * mode).
 *
 * SWIFT_WRAPPER_FUNCTIONS:
 * These functions wrap terminal operations for Swift to call without
 * parameters.
 *
 * SWIFT_KERNEL_INIT:
 * CRITICAL: Initialize and call Swift kernel components.
 * Attempt to initialize Swift terminal system.
 * Call Swift kernel main function.
 * Swift kernel has now executed and displayed its own messages.
 *
 * BOOT_INFO_PROCESSING:
 * Extract and prepare boot information for Swift kernel.
 *
 * MAIN_KERNEL_ENTRY:
 * CRITICAL: This is called from our assembly boot code.
 * Initializes Swift kernel which handles MAGI boot sequence, and coordinates
 * between C bootstrap and Swift kernel components.
 *
 * INFINITE_HALT_LOOP:
 * CRITICAL: The kernel must never return from kernel_main.
 * We halt the CPU to save power while waiting for interrupts.
 * NOTE: Since we have interrupts disabled (cli was called),
 * only Non-Maskable Interrupts (NMI) can wake us up.
 * This is fine for our current "Hello World" OS.
 * Future versions will enable interrupts and implement proper idle handling.
 *
 * C_ONLY_FALLBACK:
 * C-only kernel mode (for fallback testing).
 * Initialize VGA manually for C-only mode.
 *
 * SYSTEM_DIAGNOSTICS:
 * These provide system status and diagnostic information.
 *
 * === SUMMARY OF HYBRID KERNEL ARCHITECTURE ===
 *
 * CRITICAL C COMPONENTS:
 * 1. Multiboot header processing (boot.s)
 * 2. Early initialization and error handling
 * 3. Swift kernel initialization and coordination
 * 4. Final system halt and infinite loop
 * 5. Emergency fallback functions
 *
 * SWIFT COMPONENTS:
 * 1. Main terminal and VGA handling
 * 2. MAGI system display and theming
 * 3. Memory-safe operations
 * 4. Modern language features and type safety
 *
 * INTEGRATION BENEFITS:
 * 1. C provides low-level system control
 * 2. Swift provides safe, high-level operations
 * 3. Gradual migration path from C to Swift
 * 4. Emergency fallback to C-only mode
 * 5. Best of both worlds approach
 *
 * CALLING SEQUENCE:
 * boot.s -> kernel_main() -> initialize_swift_kernel() -> swift_kernel_main()
 *        -> [Swift does main work] -> return to C -> infinite halt loop
 */
