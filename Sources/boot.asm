    .section .text
    .globl _start
_start:
    # Set up stack (assume linker script provides _stack_top)
    la sp, _stack_top

 
    # Jump to Swift kernel entry point
    call kernel_main

hang:
    j hang
