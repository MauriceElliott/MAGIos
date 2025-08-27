.section .multiboot
.align 4
.long 0x1BADB002    # multiboot magic
.long 0x00000003    # flags (align modules on page boundaries + memory info)
.long -(0x1BADB002 + 0x00000003)  # checksum

.section .text
.global _start
_start:
    # Set up stack
    mov $stack_top, %esp

    # Reset EFLAGS
    pushl $0
    popf

    # Call Swift main function
    call _swift_main

    # Halt the system
    cli
1:  hlt
    jmp 1b

.section .bss
.align 16
stack_bottom:
.skip 16384  # 16 KB stack
stack_top:
