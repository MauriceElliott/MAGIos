/* MAGIos Linker Script - Odin Version
 * Defines the memory layout and section placement for our kernel
 * This script tells the linker how to combine object files into the final kernel binary
 */

/* Entry point of our kernel - defined in boot.s */
ENTRY(_start)

/* Define the sections of our kernel */
SECTIONS
{
    /* Start at 1MB - standard for x86 kernels (avoids BIOS/video memory) */
    . = 1M;

    /* First section: multiboot header (must be early in the file) */
    .multiboot :
    {
        /* Keep the multiboot section from boot.s */
        KEEP(*(.multiboot))
    }

    /* Text section: executable code */
    .text : ALIGN(4K) /* ALIGN to the next 4kb block of memory. */
    {
        *(.text)        /* All code sections */
        *(.text.*)      /* All code subsections */
    }

    /* Read-only data section */
    .rodata : ALIGN(4K)
    {
        *(.rodata)      /* Read-only data */
        *(.rodata.*)    /* Read-only data subsections */
    }

    /* Data section: initialized global variables */
    .data : ALIGN(4K)
    {
        *(.data)        /* Initialized data */
        *(.data.*)      /* Initialized data subsections */
    }

    /* BSS section: uninitialized global variables */
    .bss : ALIGN(4K)
    {
        *(COMMON)       /* Common symbols */
        *(.bss)         /* Uninitialized data */
        *(.bss.*)       /* Uninitialized data subsections */
        *(.stack)       /* Stack section if defined */
    }

    /* GNU stack note section (prevents linker warnings) */
    .note.GNU-stack : { *(.note.GNU-stack) }

    /* Discard unwanted sections */
    /DISCARD/ :
    {
        *(.comment)     /* Compiler version info */
        *(.eh_frame)    /* Exception handling frame (not needed for kernel) */
        *(.note.*)      /* Other note sections */
    }
}

/* === LINKER SCRIPT DOCUMENTATION ===
 *
 * MEMORY LAYOUT:
 * The kernel is loaded at 1MB (0x100000) to avoid BIOS and video memory
 * This is standard practice for x86 protected mode kernels
 *
 * SECTION ORDERING:
 * 1. .multiboot - Must be within first 8KB for GRUB to find it
 * 2. .text - Executable code (Odin and assembly functions)
 * 3. .rodata - Read-only data (strings, constants)
 * 4. .data - Initialized global variables
 * 5. .bss - Uninitialized global variables (zeroed at boot)
 *
 * ALIGNMENT:
 * Sections are aligned to 4KB boundaries for potential future paging support
 * Even though we don't use paging yet, this makes it easier to add later
 *
 * ODIN COMPATIBILITY:
 * This script works with Odin's output format
 * Odin generates standard ELF sections that fit this layout
 */
