ENTRY(_start)

SECTIONS
{
    . = 1M;

    .multiboot_header :
    {
        *(.multiboot_header)
    }

    .text : ALIGN(4K)
    {
        *(.text)
    }

    .bss : ALIGN(4K)
    {
        *(.bss)
    }
}
