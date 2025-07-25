/* MAGIos Swift Integration Linker Script
 * This script tells the linker how to organize our hybrid C/Swift kernel binary
 * It defines the memory layout for both C and Swift components
 * Based on the original linker.ld but extended for Embedded Swift support
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
    /* Contains all the actual program instructions from both C and Swift */
    .text : ALIGN(4K)  /* Align to 4KB page boundary for memory management */
    {
        *(.text)       /* Include all .text sections (executable code) */
        *(.text.*)     /* Include compiler-generated text subsections */

        /* Swift-specific code sections */
        *(.swift_text) /* Swift executable code */
        *(.swift5_protocols) /* Swift protocol metadata */
        *(.swift5_protocol_conformances) /* Swift protocol conformances */
        *(.swift5_type_metadata) /* Swift type metadata */

        /* Embedded Swift sections (minimal runtime) */
        *(.swift5_fieldmd) /* Swift field metadata */
        *(.swift5_assocty) /* Swift associated type metadata */
        *(.swift5_replace) /* Swift replacement metadata */
        *(.swift5_replac2) /* Swift replacement metadata v2 */
    }

    /* === READ-ONLY DATA SECTION === */
    /* Contains constant data that cannot be modified at runtime */
    .rodata : ALIGN(4K)  /* Align to 4KB page boundary */
    {
        *(.rodata)       /* Include all .rodata sections (string literals, constants, etc.) */
        *(.rodata.*)     /* Include compiler-generated rodata subsections */

        /* Swift-specific read-only data */
        *(.swift_rodata) /* Swift read-only data */
        *(.swift5_reflstr) /* Swift reflection strings */
        *(.swift5_typeref) /* Swift type references */
        *(.swift5_capture) /* Swift capture descriptors */

        /* Swift string literals and constants */
        *(.swift_const_data)
        *(.swift_string_table)
    }

    /* === INITIALIZED DATA SECTION === */
    /* Contains global and static variables that have initial values */
    .data : ALIGN(4K)    /* Align to 4KB page boundary */
    {
        *(.data)         /* Include all .data sections */
        *(.data.*)       /* Include compiler-generated data subsections */

        /* Swift-specific initialized data */
        *(.swift_data)   /* Swift initialized data */
        *(.swift5_mdata) /* Swift metadata */
        *(.swift5_types) /* Swift type descriptors */
    }

    /* === SWIFT-SPECIFIC METADATA SECTIONS === */
    /* These sections contain Swift runtime metadata needed even in embedded mode */
    .swift_metadata : ALIGN(4K)
    {
        /* Swift type system metadata */
        __swift5_types_start = .;
        *(.swift5_types)
        __swift5_types_end = .;

        /* Swift protocol metadata */
        __swift5_protocols_start = .;
        *(.swift5_protocols)
        __swift5_protocols_end = .;

        /* Swift protocol conformances */
        __swift5_protocol_conformances_start = .;
        *(.swift5_protocol_conformances)
        __swift5_protocol_conformances_end = .;

        /* Swift field metadata */
        __swift5_fieldmd_start = .;
        *(.swift5_fieldmd)
        __swift5_fieldmd_end = .;
    }

    /* === UNINITIALIZED DATA SECTION === */
    /* Contains global and static variables that start with zero values */
    /* This section doesn't take space in the binary file - it's allocated at runtime */
    .bss : ALIGN(4K)     /* Align to 4KB page boundary */
    {
        *(COMMON)        /* Include COMMON symbols (uninitialized globals in C) */
        *(.bss)          /* Include all .bss sections */
        *(.bss.*)        /* Include compiler-generated bss subsections */

        /* Swift-specific uninitialized data */
        *(.swift_bss)    /* Swift uninitialized data */

        /* Reserve space for Swift runtime (minimal) */
        . = ALIGN(16);   /* Align for Swift runtime requirements */
        __swift_runtime_start = .;
        . += 4096;       /* Reserve 4KB for minimal Swift runtime data */
        __swift_runtime_end = .;
    }

    /* === DEBUGGING SECTIONS === */
    /* These sections contain debugging information and are not loaded into memory */
    /* They are stripped in release builds but useful for development */
    .debug_info     0 : { *(.debug_info) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_str      0 : { *(.debug_str) }
    .debug_ranges   0 : { *(.debug_ranges) }
    .debug_loc      0 : { *(.debug_loc) }

    /* Swift debugging sections */
    .debug_swift_ast 0 : { *(.debug_swift_ast) }
    .apple_names     0 : { *(.apple_names) }
    .apple_objc      0 : { *(.apple_objc) }
    .apple_namespac  0 : { *(.apple_namespac) }
    .apple_types     0 : { *(.apple_types) }

    /* === SYMBOL DEFINITIONS === */
    /* Define symbols that can be used by both C and Swift code */
    __kernel_start = 0x00100000;
    __kernel_end = .;
    __kernel_size = __kernel_end - __kernel_start;

    /* Swift runtime symbols */
    __swift_metadata_start = __swift5_types_start;
    __swift_metadata_end = __swift5_fieldmd_end;
    __swift_metadata_size = __swift_metadata_end - __swift_metadata_start;

    /* === DISCARD UNWANTED SECTIONS === */
    /* Remove sections that are not needed in embedded environment */
    /DISCARD/ :
    {
        *(.comment)      /* Compiler comments */
        *(.eh_frame)     /* Exception handling frames (not needed in kernel) */
        *(.note.*)       /* ELF notes */

        /* Swift sections not needed in embedded mode */
        *(.swift5_builtin) /* Swift built-in types (minimal set only) */
        *(.swift_objc_*)   /* Objective-C interop (not needed) */
        *(.swift_dyld_*)   /* Dynamic loading (not needed) */

        /* Discard sections that require full Swift runtime */
        *(.swift_reflection_*)  /* Runtime reflection (disabled in embedded) */
        *(.swift_dynamic_*)     /* Dynamic features (disabled in embedded) */
    }
}

/*
 * Memory Layout Summary:
 * 0x00000000 - 0x000FFFFF : Reserved (BIOS, real mode, etc.)
 * 0x00100000 - ????????? : Our kernel sections:
 *   .multiboot    : Multiboot header (required by GRUB)
 *   .text         : C + Swift executable code
 *   .rodata       : C + Swift constants and read-only data
 *   .data         : C + Swift initialized variables
 *   .swift_metadata : Swift type system metadata
 *   .bss          : C + Swift uninitialized variables + Swift runtime space
 *
 * The linker will calculate the actual end address based on the size of our code and data
 */

/*
 * Swift Integration Notes:
 *
 * 1. EMBEDDED SWIFT COMPATIBILITY:
 *    - This linker script is designed for Embedded Swift mode
 *    - Many Swift runtime features are disabled or minimal
 *    - No dynamic loading or full reflection support
 *    - ARC (Automatic Reference Counting) is simplified
 *
 * 2. METADATA HANDLING:
 *    - Swift type metadata is preserved for basic type operations
 *    - Protocol metadata is included for protocol conformance
 *    - Reflection metadata is excluded to save space
 *
 * 3. MEMORY LAYOUT:
 *    - Swift code is intermixed with C code in .text section
 *    - Swift constants are placed with C constants in .rodata
 *    - Dedicated .swift_metadata section for type system data
 *    - Reserved space in .bss for minimal Swift runtime
 *
 * 4. LINKING REQUIREMENTS:
 *    - Link with Swift static library: libMAGIosSwift.a
 *    - Use i686-elf-ld with this script: -T linker_swift.ld
 *    - Ensure Swift objects are compiled with matching target triple
 *
 * 5. DEBUGGING:
 *    - Swift debugging sections are preserved in debug builds
 *    - Can be stripped in release builds with --strip-debug
 *    - GDB can debug both C and Swift code with proper symbols
 */
