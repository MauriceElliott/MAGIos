/*
 * MAGIos Kernel - Swift Integration Version
 * This is the hybrid C/Swift kernel implementation
 * It provides basic bootstrapping in C and then calls Swift kernel functions
 */

#include <stddef.h> /* For size_t and NULL definitions */
#include <stdint.h> /* For fixed-width integer types (uint8_t, uint16_t, etc.) */

/* Include our Swift bridge header for interoperability */
#include "include/kernel_bridge.h"

/* === MULTIBOOT INFORMATION HANDLING ===
 * CRITICAL: Process multiboot information from GRUB
 * This data is passed from the bootloader and contains system information
 */
typedef struct multiboot_info {
  uint32_t flags;
  uint32_t mem_lower;
  uint32_t mem_upper;
  uint32_t boot_device;
  uint32_t cmdline;
  uint32_t mods_count;
  uint32_t mods_addr;
  /* ... other fields as needed ... */
} multiboot_info_t;

/* === LEGACY C FUNCTIONS ===
 * These remain in C for compatibility and low-level operations
 * Some may be gradually moved to Swift in future phases
 */

/* Legacy VGA helper functions for fallback/debugging */
static inline uint8_t vga_entry_color_c(vga_color_t fg, vga_color_t bg) {
  return fg | bg << 4;
}

static inline uint16_t vga_entry_c(unsigned char uc, uint8_t color) {
  return (uint16_t)uc | (uint16_t)color << 8;
}

/* === EMERGENCY FALLBACK FUNCTIONS ===
 * These provide basic output if Swift kernel fails
 * CRITICAL: These ensure we can always display error messages
 */
static void emergency_print(const char *message) {
  volatile uint16_t *vga_buffer = (uint16_t *)VGA_MEMORY;
  uint8_t color = VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK);

  /* Clear first line for emergency message */
  for (int i = 0; i < VGA_WIDTH; i++) {
    vga_buffer[i] = VGA_ENTRY(' ', color);
  }

  /* Display emergency message */
  int pos = 0;
  while (message[pos] && pos < VGA_WIDTH - 1) {
    vga_buffer[pos] = VGA_ENTRY(message[pos], color);
    pos++;
  }
}

/* === KERNEL PANIC FUNCTION ===
 * CRITICAL: Handle kernel panic situations
 */
static void kernel_panic(const char *message) {
  /* Disable interrupts to prevent further issues */
  __asm__ volatile("cli");

  emergency_print("KERNEL PANIC: ");
  emergency_print(message);

  /* Halt the system */
  while (1) {
    __asm__ volatile("hlt");
  }
}

/* === SWIFT KERNEL INITIALIZATION ===
 * CRITICAL: Initialize and call Swift kernel components
 */
static void initialize_swift_kernel(void) {
  /* Attempt to initialize Swift terminal system */
  __asm__ volatile("" ::: "memory"); /* Memory barrier */

  /* Call Swift kernel main function */
  swift_kernel_main();

  __asm__ volatile("" ::: "memory"); /* Memory barrier */
}

/* === BOOT INFORMATION PROCESSING ===
 * Extract and prepare boot information for Swift kernel
 */
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

/* === MAIN KERNEL FUNCTION ===
 * CRITICAL: This is called from our assembly boot code
 * This function coordinates between C bootstrap and Swift kernel
 */
void kernel_main(void) {
  /* === EARLY INITIALIZATION === */
  /* Set up basic error handling */

  /* === SWIFT KERNEL INTEGRATION === */
  /* Try to initialize and run Swift kernel */
  __asm__ volatile("" ::: "memory"); /* Compiler barrier */

  /* Initialize Swift kernel - this does the main work */
  initialize_swift_kernel();

  /* === POST-SWIFT PROCESSING === */
  /* Swift kernel has completed its initialization and display */
  /* Now we handle the final system state */

  /* Display C kernel status message */
  swift_terminal_setcolor(
      VGA_ENTRY_COLOR(VGA_COLOR_DARK_GREY, VGA_COLOR_BLACK));
  swift_terminal_writestring("C kernel: Swift integration successful\n");

  /* === INFINITE IDLE LOOP ===
   * CRITICAL: The kernel must never return from kernel_main
   * We halt the CPU to save power while waiting for interrupts
   */
  __asm__ volatile("cli"); /* Disable interrupts for clean halt */

  while (1) {
    __asm__ volatile(
        "hlt"); /* Halt instruction - stops CPU until next interrupt */
                /*
                 * NOTE: Since we have interrupts disabled (cli was called),
                 * only Non-Maskable Interrupts (NMI) can wake us up.
                 * This is fine for our current "Hello World" OS.
                 * Future versions will enable interrupts and implement proper idle
                 * handling.
                 */
  }

  /* This point should never be reached */
}

/* === ALTERNATIVE ENTRY POINTS ===
 * These provide different kernel modes for testing and development
 */

/* C-only kernel mode (for fallback testing) */
void kernel_main_c_only(void) {
  /* Initialize VGA manually for C-only mode */
  volatile uint16_t *terminal_buffer = (uint16_t *)VGA_MEMORY;
  uint8_t color = VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);

  /* Clear screen */
  for (size_t y = 0; y < VGA_HEIGHT; y++) {
    for (size_t x = 0; x < VGA_WIDTH; x++) {
      const size_t index = y * VGA_WIDTH + x;
      terminal_buffer[index] = VGA_ENTRY(' ', color);
    }
  }

  /* Display C-only message */
  const char *message = "MAGIos - C-only mode (Swift disabled)";
  size_t row = 0;
  size_t col = 0;

  for (size_t i = 0; message[i] != '\0'; i++) {
    if (message[i] == '\n') {
      row++;
      col = 0;
      continue;
    }

    const size_t index = row * VGA_WIDTH + col;
    terminal_buffer[index] = VGA_ENTRY(message[i], color);
    col++;
  }

  /* Infinite loop */
  while (1) {
    __asm__ volatile("hlt");
  }
}

/* === DEBUGGING FUNCTIONS ===
 * These are available for development and troubleshooting
 */

#ifdef DEBUG
void debug_print(const char *message) {
  swift_terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_BROWN, VGA_COLOR_BLACK));
  swift_terminal_writestring("[DEBUG] ");
  swift_terminal_writestring(message);
  swift_terminal_writestring("\n");
}
#endif

/* === SYSTEM INFORMATION FUNCTIONS ===
 * These provide system status and diagnostic information
 */
void display_system_diagnostics(void) {
  swift_terminal_setcolor(
      VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_BROWN, VGA_COLOR_BLACK));
  swift_terminal_writestring("System Diagnostics:\n");

  swift_terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
  swift_terminal_writestring("- C Kernel: Active (integration mode)\n");
  swift_terminal_writestring("- Swift Kernel: Active (embedded mode)\n");
  swift_terminal_writestring("- Boot Protocol: Multiboot v1\n");
  swift_terminal_writestring("- Architecture: i686-elf\n\n");
}

/*
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
