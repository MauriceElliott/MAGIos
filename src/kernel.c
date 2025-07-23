/*
 * MAGIos Kernel - Main C Code
 * This is the heart of our operating system kernel
 * It provides basic text output capabilities for a "Hello World" OS
 */

#include <stddef.h> /* For size_t and NULL definitions */
#include <stdint.h> /* For fixed-width integer types (uint8_t, uint16_t, etc.) */

/* === VGA TEXT MODE CONSTANTS ===
 * CRITICAL: These define how we interact with the VGA text buffer
 * VGA text mode is the simplest way to display text on x86 systems
 */
#define VGA_WIDTH 80  /* Standard VGA text mode is 80 characters wide */
#define VGA_HEIGHT 25 /* Standard VGA text mode is 25 lines tall */
#define VGA_MEMORY                                                             \
  0xB8000 /* Physical memory address where VGA text buffer lives */

/* === VGA COLOR ENUMERATION ===
 * NON-CRITICAL: These make our code more readable than using raw numbers
 * VGA text mode supports 16 foreground and 8 background colors
 */
typedef enum {
  VGA_COLOR_BLACK = 0,          /* 0000 in binary */
  VGA_COLOR_BLUE = 1,           /* 0001 in binary */
  VGA_COLOR_GREEN = 2,          /* 0010 in binary */
  VGA_COLOR_CYAN = 3,           /* 0011 in binary */
  VGA_COLOR_RED = 4,            /* 0100 in binary */
  VGA_COLOR_MAGENTA = 5,        /* 0101 in binary */
  VGA_COLOR_BROWN = 6,          /* 0110 in binary */
  VGA_COLOR_LIGHT_GREY = 7,     /* 0111 in binary */
  VGA_COLOR_DARK_GREY = 8,      /* 1000 in binary */
  VGA_COLOR_LIGHT_BLUE = 9,     /* 1001 in binary */
  VGA_COLOR_LIGHT_GREEN = 10,   /* 1010 in binary */
  VGA_COLOR_LIGHT_CYAN = 11,    /* 1011 in binary */
  VGA_COLOR_LIGHT_RED = 12,     /* 1100 in binary */
  VGA_COLOR_LIGHT_MAGENTA = 13, /* 1101 in binary */
  VGA_COLOR_LIGHT_BROWN = 14,   /* 1110 in binary */
  VGA_COLOR_WHITE = 15,         /* 1111 in binary */
} vga_color;

/* === VGA COLOR HELPER FUNCTION ===
 * NON-CRITICAL: Makes color handling easier
 * Combines foreground and background colors into a single byte
 * Format: BBBBFFFF (4 bits background, 4 bits foreground)
 */
static inline uint8_t vga_entry_color(vga_color fg, vga_color bg) {
  return fg | bg << 4; /* Shift background color to upper 4 bits */
}

/* === VGA CHARACTER ENTRY HELPER FUNCTION ===
 * CRITICAL: Creates a VGA text mode entry (character + attributes)
 * Each character in VGA text mode takes 2 bytes:
 * - Low byte: ASCII character code
 * - High byte: Color attributes (background and foreground colors)
 */
static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
  return (uint16_t)uc | (uint16_t)color << 8;
}

/* === TERMINAL STATE VARIABLES ===
 * CRITICAL: These track our current cursor position and display settings
 * Global variables are initialized to 0 automatically in the BSS section
 */
static size_t terminal_row;       /* Current row (0-24) */
static size_t terminal_column;    /* Current column (0-79) */
static uint8_t terminal_color;    /* Current color attributes */
static uint16_t *terminal_buffer; /* Pointer to VGA text buffer in memory */

/* === TERMINAL INITIALIZATION FUNCTION ===
 * CRITICAL: Sets up our text display system
 * This must be called before any text output
 */
void terminal_initialize(void) {
  /* Set cursor to top-left corner */
  terminal_row = 0;
  terminal_column = 0;

  /* Set default colors (cyan text on black background for that retro feel) */
  terminal_color = vga_entry_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);

  /* Map the VGA text buffer to our pointer */
  /* This is direct hardware access - we're writing to video memory */
  terminal_buffer = (uint16_t *)VGA_MEMORY;

  /* Clear the entire screen by filling with spaces */
  for (size_t y = 0; y < VGA_HEIGHT; y++) {
    for (size_t x = 0; x < VGA_WIDTH; x++) {
      const size_t index =
          y * VGA_WIDTH + x; /* Convert 2D coords to 1D index */
      terminal_buffer[index] = vga_entry(' ', terminal_color);
    }
  }
}

/* === SINGLE CHARACTER OUTPUT FUNCTION ===
 * CRITICAL: Displays one character at current cursor position
 * Handles special characters like newline
 */
void terminal_putchar(char c) {
  /* Handle newline character */
  if (c == '\n') {
    terminal_column = 0;                /* Move to start of line */
    if (++terminal_row == VGA_HEIGHT) { /* Move to next row */
      terminal_row =
          0; /* Wrap to top if at bottom (NON-CRITICAL: could scroll instead) */
    }
    return;
  }

  /* Calculate position in linear buffer */
  const size_t index = terminal_row * VGA_WIDTH + terminal_column;

  /* Write character and color to VGA buffer */
  terminal_buffer[index] = vga_entry(c, terminal_color);

  /* Advance cursor position */
  if (++terminal_column == VGA_WIDTH) { /* If we hit the right edge */
    terminal_column = 0;                /* Wrap to next line */
    if (++terminal_row == VGA_HEIGHT) {
      terminal_row = 0; /* Wrap to top (NON-CRITICAL: could scroll instead) */
    }
  }
}

/* === BUFFER OUTPUT FUNCTION ===
 * NON-CRITICAL: Convenience function for outputting a buffer of known size
 * Could be inlined into terminal_writestring, but kept separate for clarity
 */
void terminal_write(const char *data, size_t size) {
  for (size_t i = 0; i < size; i++) {
    terminal_putchar(data[i]);
  }
}

/* === STRING LENGTH HELPER FUNCTION ===
 * CRITICAL: We can't use standard library strlen, so we implement our own
 * Counts characters until we hit null terminator ('\0')
 */
size_t strlen(const char *str) {
  size_t len = 0;
  while (str[len]) { /* Continue until we hit '\0' */
    len++;
  }
  return len;
}

/* === STRING OUTPUT FUNCTION ===
 * CRITICAL: Main function for displaying null-terminated strings
 * This is what we'll use most often for text output
 */
void terminal_writestring(const char *data) {
  terminal_write(data, strlen(data));
}

/* === COLOR CHANGE HELPER FUNCTION ===
 * NON-CRITICAL: Convenience function to change text colors
 * Makes the demo more visually appealing
 */
void terminal_setcolor(uint8_t color) { terminal_color = color; }

/* === MAIN KERNEL FUNCTION ===
 * CRITICAL: This is called from our assembly boot code
 * This is where our operating system actually starts doing work
 */
void kernel_main(void) {
  /* === INITIALIZE DISPLAY SYSTEM ===
   * CRITICAL: Must be first - sets up our ability to show output
   */
  terminal_initialize();

  /* === DISPLAY BOOT MESSAGE ===
   * This is our "Hello World" - proof that our OS is working
   * The Evangelion theming is NON-CRITICAL but fun
   */

  /* Header message in red */
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK));
  terminal_writestring("MAGI SYSTEM STARTUP SEQUENCE INITIATED\n");
  terminal_writestring("======================================\n\n");

  /* System status messages */
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK));
  terminal_writestring("CASPER... ");
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));
  terminal_writestring("ONLINE\n");

  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK));
  terminal_writestring("MELCHIOR... ");
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));
  terminal_writestring("ONLINE\n");

  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK));
  terminal_writestring("BALTHASAR... ");
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));
  terminal_writestring("ONLINE\n\n");

  /* Main welcome message */
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_MAGENTA, VGA_COLOR_BLACK));
  terminal_writestring("MAGIos v0.1.0 - Welcome to Terminal Dogma\n");
  terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
  terminal_writestring("32-bit Operating System Successfully Initialized\n\n");

  /* Basic system information */
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_BROWN, VGA_COLOR_BLACK));
  terminal_writestring("System Status:\n");
  terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
  terminal_writestring("- Kernel loaded at 1MB physical memory\n");
  terminal_writestring("- VGA text mode: 80x25 characters\n");
  terminal_writestring("- Memory management: Basic (no paging yet)\n");
  terminal_writestring("- Interrupts: Disabled (GRUB default)\n\n");

  /* Final message */
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK));
  terminal_writestring("Hello, World from MAGIos!\n");
  terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK));
  terminal_writestring("System is now in infinite idle loop...\n");

  /* === INFINITE IDLE LOOP ===
   * CRITICAL: The kernel must never return from kernel_main
   * We halt the CPU to save power while waiting for interrupts
   * Since we haven't set up interrupt handlers yet, this effectively stops the
   * system
   */
  while (1) {
    __asm__("hlt"); /* Halt instruction - stops CPU until next interrupt */
                    /*
                     * NOTE: Since we have interrupts disabled (cli was called in boot.s),
                     * only Non-Maskable Interrupts (NMI) can wake us up.
                     * This is fine for our basic "Hello World" OS.
                     */
  }

  /* This point should never be reached */
}

/*
 * === SUMMARY OF WHAT THIS KERNEL DOES ===
 *
 * CRITICAL FUNCTIONS:
 * 1. Sets up VGA text mode output system
 * 2. Displays "Hello World" style boot messages
 * 3. Enters infinite loop to prevent returning to bootloader
 *
 * NON-CRITICAL FEATURES:
 * 1. Evangelion-themed messages (aesthetic choice)
 * 2. Multiple colors (could use single color)
 * 3. System information display (informational only)
 * 4. Helper functions for convenience
 *
 * WHAT'S MISSING (for future phases):
 * 1. Interrupt handling
 * 2. Memory management beyond basic stack
 * 3. Input handling (keyboard, mouse)
 * 4. Process management
 * 5. File system
 * 6. Graphics mode support
 */
