/* MAGIos Swift Integration Linker Script
 * See LINKER_SCRIPT_DOCUMENTATION at bottom for detailed documentation
 */

ENTRY(start) /* ENTRY_POINT_DEFINITION */

SECTIONS
{
    . = 0x00100000; /* KERNEL_LOAD_ADDRESS */

    /* MULTIBOOT_HEADER_SECTION */
    .multiboot : ALIGN(4K)
    {
        *(.multiboot)
    }

    /* EXECUTABLE_CODE_SECTION */
    .text : ALIGN(4K)
    {
        *(.text)
        *(.text.*)
        *(.swift_text)
        *(.swift5_protocols)
        *(.swift5_protocol_conformances)
        *(.swift5_type_metadata)
        *(.swift5_fieldmd)
        *(.swift5_assocty)
        *(.swift5_replace)
        *(.swift5_replac2)
    }

    /* READ_ONLY_DATA_SECTION */
    .rodata : ALIGN(4K)
    {
        *(.rodata)
        *(.rodata.*)
        *(.swift_rodata)
        *(.swift5_reflstr)
        *(.swift5_typeref)
        *(.swift5_capture)
        *(.swift_const_data)
        *(.swift_string_table)
    }

    /* INITIALIZED_DATA_SECTION */
    .data : ALIGN(4K)
    {
        *(.data)
        *(.data.*)
        *(.swift_data)
        *(.swift5_mdata)
        *(.swift5_types)
    }

    /* SWIFT_METADATA_SECTIONS */
    .swift_metadata : ALIGN(4K)
    {
        __swift5_types_start = .;
        *(.swift5_types)
        __swift5_types_end = .;

        __swift5_protocols_start = .;
        *(.swift5_protocols)
        __swift5_protocols_end = .;

        __swift5_protocol_conformances_start = .;
        *(.swift5_protocol_conformances)
        __swift5_protocol_conformances_end = .;

        __swift5_fieldmd_start = .;
        *(.swift5_fieldmd)
        __swift5_fieldmd_end = .;
    }

    /* UNINITIALIZED_DATA_SECTION */
    .bss : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
        *(.bss.*)
        *(.swift_bss)

        . = ALIGN(16); /* SWIFT_RUNTIME_ALIGNMENT */
        __swift_runtime_start = .;
        . += 4096;
        __swift_runtime_end = .;
    }

    /* DEBUGGING_SECTIONS */
    .debug_info     0 : { *(.debug_info) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_str      0 : { *(.debug_str) }
    .debug_ranges   0 : { *(.debug_ranges) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_swift_ast 0 : { *(.debug_swift_ast) }
    .apple_names     0 : { *(.apple_names) }
    .apple_objc      0 : { *(.apple_objc) }
    .apple_namespac  0 : { *(.apple_namespac) }
    .apple_types     0 : { *(.apple_types) }

    /* SYMBOL_DEFINITIONS */
    __kernel_start = 0x00100000;
    __kernel_end = .;
    __kernel_size = __kernel_end - __kernel_start;
    __swift_metadata_start = __swift5_types_start;
    __swift_metadata_end = __swift5_fieldmd_end;
    __swift_metadata_size = __swift_metadata_end - __swift_metadata_start;

    /* DISCARD_UNWANTED_SECTIONS */
    /DISCARD/ :
    {
        *(.comment)
        *(.eh_frame)
        *(.note.*)
        *(.swift5_builtin)
        *(.swift_objc_*)
        *(.swift_dyld_*)
        *(.swift_reflection_*)
        *(.swift_dynamic_*)
    }
}

/*
 * === LINKER_SCRIPT_DOCUMENTATION ===
 *
 * ENTRY_POINT_DEFINITION:
 * ENTRY(start) - tells the linker where execution should start
 * 'start' is the symbol name from our boot.s assembly file
 *
 * KERNEL_LOAD_ADDRESS:
 * Start kernel at 1MB (0x00100000) in physical memory
 * This is the standard location for OS kernels - it's above the first 1MB
 * which contains BIOS data, real mode interrupt vectors, and other low-memory structures
 *
 * MULTIBOOT_HEADER_SECTION:
 * CRITICAL: This section contains the multiboot header that GRUB needs
 * It must be within the first 8KB of the kernel binary
 *
 * EXECUTABLE_CODE_SECTION:
 * Contains all the actual program instructions from both C and Swift
 * Align to 4KB page boundary for memory management
 * Swift-specific code sections:
 * - .swift_text: Swift executable code
 * - .swift5_protocols: Swift protocol metadata
 * - .swift5_protocol_conformances: Swift protocol conformances
 * - .swift5_type_metadata: Swift type metadata
 * - Embedded Swift sections (minimal runtime)
 *
 * READ_ONLY_DATA_SECTION:
 * Contains constant data that cannot be modified at runtime
 * Align to 4KB page boundary
 * Swift-specific read-only data:
 * - .swift_rodata: Swift read-only data
 * - .swift5_reflstr: Swift reflection strings
 * - .swift5_typeref: Swift type references
 * - .swift5_capture: Swift capture descriptors
 * - Swift string literals and constants
 *
 * INITIALIZED_DATA_SECTION:
 * Contains global and static variables that have initial values
 * Align to 4KB page boundary
 * Swift-specific initialized data:
 * - .swift_data: Swift initialized data
 * - .swift5_mdata: Swift metadata
 * - .swift5_types: Swift type descriptors
 *
 * SWIFT_METADATA_SECTIONS:
 * These sections contain Swift runtime metadata needed even in embedded mode
 * Swift type system metadata, protocol metadata, protocol conformances, field metadata
 * Provides start/end symbols for runtime access
 *
 * UNINITIALIZED_DATA_SECTION:
 * Contains global and static variables that start with zero values
 * This section doesn't take space in the binary file - it's allocated at runtime
 * SWIFT_RUNTIME_ALIGNMENT: Align for Swift runtime requirements
 * Reserve 4KB for minimal Swift runtime data
 *
 * DEBUGGING_SECTIONS:
 * These sections contain debugging information and are not loaded into memory
 * They are stripped in release builds but useful for development
 * Swift debugging sections for development and debugging
 *
 * SYMBOL_DEFINITIONS:
 * Define symbols that can be used by both C and Swift code
 * Kernel memory boundaries and Swift runtime symbols
 *
 * DISCARD_UNWANTED_SECTIONS:
 * Remove sections that are not needed in embedded environment
 * Swift sections not needed in embedded mode:
 * - .swift5_builtin: Swift built-in types (minimal set only)
 * - .swift_objc_*: Objective-C interop (not needed)
 * - .swift_dyld_*: Dynamic loading (not needed)
 * - .swift_reflection_*: Runtime reflection (disabled in embedded)
 * - .swift_dynamic_*: Dynamic features (disabled in embedded)
 *
 * MEMORY_LAYOUT_SUMMARY:
 * 0x00000000 - 0x000FFFFF : Reserved (BIOS, real mode, etc.)
 * 0x00100000 - ????????? : Our kernel sections:
 *   .multiboot    : Multiboot header (required by GRUB)
 *   .text         : C + Swift executable code
 *   .rodata       : C + Swift constants and read-only data
 *   .data         : C + Swift initialized variables
 *   .swift_metadata : Swift type system metadata
 *   .bss          : C + Swift uninitialized variables + Swift runtime space
 *
 * SWIFT_INTEGRATION_NOTES:
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
 *    - Use i686-elf-ld with this script: -T linker.ld
 *    - Ensure Swift objects are compiled with matching target triple
 *
 * 5. DEBUGGING:
 *    - Swift debugging sections are preserved in debug builds
 *    - Can be stripped in release builds with --strip-debug
 *    - GDB can debug both C and Swift code with proper symbols
 */
