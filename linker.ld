/* MAGIos Linker Script
 * This script tells the linker how to organize our kernel binary in memory
 * It defines the memory layout and section arrangement for our OS kernel
 */

/* === ENTRY POINT DEFINITION === */
/* Tell the linker where execution should start */
ENTRY(start)  /* 'start' is the symbol name from our boot.s assembly file */

/* === MEMORY LAYOUT SECTIONS === */
SECTIONS
{
    /* === KERNEL LOAD ADDRESS === */
    /* Start kernel at 1MB (0x00100000) in physical memory */
    /* This is the standard location for OS kernels - it's above the first 1MB */
    /* which contains BIOS data, real mode interrupt vectors, and other low-memory structures */
    . = 0x00100000;

    /* === MULTIBOOT HEADER SECTION === */
    /* CRITICAL: This section contains the multiboot header that GRUB needs */
    /* It must be within the first 8KB of the kernel binary */
    .multiboot : ALIGN(4K)
    {
        *(.multiboot)  /* Include all .multiboot sections from input files */
    }

    /* === EXECUTABLE CODE SECTION === */
    /* Contains all the actual program instructions */
    .text : ALIGN(4K)  /* Align to 4KB page boundary for memory management */
    {
        *(.text)       /* Include all .text sections (executable code) */
    }

    /* === READ-ONLY DATA SECTION === */
    /* Contains constant data that cannot be modified at runtime */
    .rodata : ALIGN(4K)  /* Align to 4KB page boundary */
    {
        *(.rodata)       /* Include all .rodata sections (string literals, constants, etc.) */
    }

    /* === INITIALIZED DATA SECTION === */
    /* Contains global and static variables that have initial values */
    .data : ALIGN(4K)    /* Align to 4KB page boundary */
    {
        *(.data)         /* Include all .data sections */
    }

    /* === UNINITIALIZED DATA SECTION === */
    /* Contains global and static variables that start with zero values */
    /* This section doesn't take space in the binary file - it's allocated at runtime */
    .bss : ALIGN(4K)     /* Align to 4KB page boundary */
    {
        *(COMMON)        /* Include COMMON symbols (uninitialized globals in C) */
        *(.bss)          /* Include all .bss sections */
    }

    /* Note: The 4KB alignment is important for:
     * 1. Memory management (pages are 4KB on x86)
     * 2. Performance (aligned memory access is faster)
     * 3. Future implementation of paging/virtual memory
     */
}

/*
 * Memory Layout Summary:
 * 0x00000000 - 0x000FFFFF : Reserved (BIOS, real mode, etc.)
 * 0x00100000 - ????????? : Our kernel sections (.multiboot, .text, .rodata, .data, .bss)
 *
 * The linker will calculate the actual end address based on the size of our code and data
 */
