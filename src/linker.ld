/* MAGIos RISC-V 64-bit Linker Script */
/* Terminal Dogma Memory Layout - RISC-V Virtual Memory */

ENTRY(_start)

/* RISC-V QEMU virt machine memory layout */
MEMORY
{
    /* RAM starts at 0x80000000 in RISC-V QEMU virt machine */
    /* We'll load our kernel at the beginning of RAM */
    RAM (rwx) : ORIGIN = 0x80200000, LENGTH = 128M
}

/* Define the program headers */
PHDRS
{
    text PT_LOAD FLAGS(5);   /* Read + Execute */
    data PT_LOAD FLAGS(6);   /* Read + Write */
}

SECTIONS
{
    /* Kernel starts at beginning of RAM */
    . = 0x80200000;

    /* MAGI System - Code Section */
    .text : ALIGN(4K)
    {
        PROVIDE(_text_start = .);

        /* Boot code must come first */
        *(.text.boot)

        /* Rest of the code */
        *(.text)
        *(.text.*)

        /* Read-only data in text section */
        *(.rodata)
        *(.rodata.*)

        PROVIDE(_text_end = .);
    } : text

    /* CASPER System - Initialized Data Section */
    .data : ALIGN(4K)
    {
        PROVIDE(_data_start = .);

        *(.data)
        *(.data.*)

        /* Global offset table for position-independent code */
        *(.got)
        *(.got.*)

        PROVIDE(_data_end = .);
    } : data

    /* MELCHIOR System - Uninitialized Data Section */
    .bss : ALIGN(4K)
    {
        PROVIDE(_bss_start = .);

        *(.bss)
        *(.bss.*)
        *(COMMON)

        PROVIDE(_bss_end = .);
    } : data

    /* BALTHASAR System - Stack Section */
    .stack : ALIGN(4K)
    {
        PROVIDE(_stack_bottom = .);
        . += 64K;  /* 64KB stack size */
        PROVIDE(_stack_top = .);
    } : data

    /* Kernel heap starts after stack */
    PROVIDE(_heap_start = .);

    /* End of kernel memory */
    PROVIDE(_kernel_end = .);

    /* Debug information (not loaded into memory) */
    .debug_info     0 : { *(.debug_info) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_ranges   0 : { *(.debug_ranges) }

    /* Discard sections we don't need */
    /DISCARD/ :
    {
        *(.comment)
        *(.note.*)
        *(.eh_frame)
        *(.eh_frame_hdr)
    }
}

/* Provide symbols for memory layout information */
PROVIDE(_memory_start = ORIGIN(RAM));
PROVIDE(_memory_size = LENGTH(RAM));

/* Assert that kernel fits in memory */
ASSERT(_kernel_end < (ORIGIN(RAM) + LENGTH(RAM)), "Kernel too large for available RAM")

/* Assert proper alignment */
ASSERT((_text_start & 0xFFF) == 0, "Text section not page-aligned")
ASSERT((_data_start & 0xFFF) == 0, "Data section not page-aligned")
ASSERT((_bss_start & 0xFFF) == 0, "BSS section not page-aligned")
ASSERT((_stack_bottom & 0xFFF) == 0, "Stack not page-aligned")
