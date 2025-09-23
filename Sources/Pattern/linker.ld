OUTPUT_ARCH(riscv)

ENTRY(_start)

SECTIONS
{
    . = 0x80200000; /* Changed from 800000000 to avoid quemu collision with openSBI*/

    .text : {
        *(.text.boot)
        *(.text)
    }

    .rodata : {
        *(.rodata*)
    }

    .data : {
        *(.data*)
    }

    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    }

    . = ALIGN(16);

    _stack_top = . + 0x10000; /* 64kb stack */
}
