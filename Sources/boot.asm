; Boot entry point
section .multiboot_header
header_start:
    dd 0xe85250d6                ; multiboot2 magic
    dd 0                         ; architecture (i386) 
    dd header_end - header_start ; header length
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)) ; checksum
    
    ; End tag
    dw 0, 0
    dd 8
header_end:

section .bss
align 16
stack_bottom:
    resb 16384
stack_top:

section .text
global _start
extern kernel_main

_start:
    mov esp, stack_top
    call kernel_main
    cli
    hlt
