/*
 * MAGIos Kernel - Swift Integration Version
 * See KERNEL_ARCHITECTURE_NOTES at bottom for detailed documentation
 */

#define KERNEL_BRIDGE_HEADER "include/kernel_bridge.h"
#define SWIFT_KERNEL_DIR "../swernel/"

#include <stddef.h>
#include <stdint.h>
#include KERNEL_BRIDGE_HEADER

// Forward declarations
void terminal_putchar(char c);

// SWIFT_RUNTIME_STUBS
void free(void *ptr) { (void)ptr; }

int posix_memalign(void **memptr, size_t alignment, size_t size) {
  (void)memptr;
  (void)alignment;
  (void)size;
  return -1; // POSIX_MEMALIGN_ERROR
}

void *memset(void *s, int c, size_t n) {
  unsigned char *p = (unsigned char *)s;
  while (n--) {
    *p++ = (unsigned char)c;
  }
  return s;
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

// LEGACY_VGA_HELPERS
static inline uint8_t vga_entry_color_c(vga_color_t fg, vga_color_t bg) {
  return fg | bg << 4;
}

static inline uint16_t vga_entry_c(unsigned char uc, uint8_t color) {
  return (uint16_t)uc | (uint16_t)color << 8;
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

void *memmove(void *dest, const void *src, size_t n) {
  unsigned char *d = (unsigned char *)dest;
  const unsigned char *s = (const unsigned char *)src;

  if (d < s) {
    for (size_t i = 0; i < n; i++) {
      d[i] = s[i];
    }
  } else if (d > s) {
    for (size_t i = n; i > 0; i--) {
      d[i - 1] = s[i - 1];
    }
  }
  return dest;
}

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

// CHARACTER_CONSTANTS_FOR_SWIFT
char get_char_O(void) { return 'O'; }
char get_char_K(void) { return 'K'; }
char get_char_space(void) { return ' '; }
char get_char_newline(void) { return '\n'; }
char get_char_h(void) { return 'h'; }
char get_char_e(void) { return 'e'; }
char get_char_l(void) { return 'l'; }
char get_char_o(void) { return 'o'; }
char get_char_comma(void) { return ','; }
char get_char_f(void) { return 'f'; }
char get_char_r(void) { return 'r'; }
char get_char_m(void) { return 'm'; }
char get_char_s(void) { return 's'; }
char get_char_w(void) { return 'w'; }
char get_char_i(void) { return 'i'; }
char get_char_t(void) { return 't'; }
char get_char_exclamation(void) { return '!'; }

uint8_t get_color_green(void) {
  return VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
}
uint8_t get_color_cyan(void) {
  return VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);
}
uint8_t get_color_yellow(void) {
  return VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_BROWN, VGA_COLOR_BLACK);
}

// SWIFT_WRAPPER_FUNCTIONS
void swift_putchar_h(void) { terminal_putchar('h'); }
void swift_putchar_e(void) { terminal_putchar('e'); }
void swift_putchar_l(void) { terminal_putchar('l'); }
void swift_putchar_o(void) { terminal_putchar('o'); }
void swift_putchar_comma(void) { terminal_putchar(','); }
void swift_putchar_space(void) { terminal_putchar(' '); }
void swift_putchar_f(void) { terminal_putchar('f'); }
void swift_putchar_r(void) { terminal_putchar('r'); }
void swift_putchar_m(void) { terminal_putchar('m'); }
void swift_putchar_s(void) { terminal_putchar('s'); }
void swift_putchar_w(void) { terminal_putchar('w'); }
void swift_putchar_i(void) { terminal_putchar('i'); }
void swift_putchar_t(void) { terminal_putchar('t'); }
void swift_putchar_exclamation(void) { terminal_putchar('!'); }
void swift_putchar_newline(void) { terminal_putchar('\n'); }

void swift_set_color_yellow(void) {
  terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_BROWN, VGA_COLOR_BLACK));
}

// SWIFT_KERNEL_INIT
static void initialize_swift_kernel(void) {
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
  initialize_swift_kernel();
  __asm__ volatile("cli");

  while (1) {
    __asm__ volatile("hlt"); // INFINITE_HALT_LOOP
  }
}

// C_ONLY_FALLBACK
void kernel_main_c_only(void) {
  volatile uint16_t *terminal_buffer = (uint16_t *)VGA_MEMORY;
  uint8_t color = VGA_ENTRY_COLOR(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);

  for (size_t y = 0; y < VGA_HEIGHT; y++) {
    for (size_t x = 0; x < VGA_WIDTH; x++) {
      const size_t index = y * VGA_WIDTH + x;
      terminal_buffer[index] = VGA_ENTRY(' ', color);
    }
  }

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

  while (1) {
    __asm__ volatile("hlt");
  }
}

#ifdef DEBUG
void debug_print(const char *message) {
  swift_terminal_setcolor(VGA_ENTRY_COLOR(VGA_COLOR_BROWN, VGA_COLOR_BLACK));
  swift_terminal_writestring("[DEBUG] ");
  swift_terminal_writestring(message);
  swift_terminal_writestring("\n");
}
#endif

// SYSTEM_DIAGNOSTICS
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
 * === KERNEL_ARCHITECTURE_NOTES ===
 *
 * SWIFT_RUNTIME_STUBS:
 * Minimal implementations of standard library functions required by Swift
 * runtime. These provide basic functionality for the embedded Swift kernel
 * environment. free() - In a real kernel, this would free memory from a heap
 * allocator. For now, we ignore free calls since we don't have dynamic
 * allocation.
 *
 * POSIX_MEMALIGN_ERROR:
 * Minimal memory allocation - for embedded Swift we avoid dynamic allocation.
 * Return error to force Swift to use stack allocation where possible.
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
 * This function coordinates between C bootstrap and Swift kernel.
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
