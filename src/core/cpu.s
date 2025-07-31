; MAGIos CPU Assembly Helper Functions
; Provides CPU instruction wrappers for Odin kernel

section .text

; Disable interrupts
global cpu_disable_interrupts:function (cpu_disable_interrupts.end - cpu_disable_interrupts)
cpu_disable_interrupts:
    cli
    ret
.end:

; Halt CPU
global cpu_halt:function (cpu_halt.end - cpu_halt)
cpu_halt:
    hlt
    ret
.end:

; Halt CPU forever (infinite loop)
global cpu_halt_forever:function (cpu_halt_forever.end - cpu_halt_forever)
cpu_halt_forever:
    cli                ; Disable interrupts first
.loop:
    hlt                ; Halt until interrupt
    jmp .loop          ; Jump back (in case of NMI)
.end:

; Enable interrupts
global cpu_enable_interrupts:function (cpu_enable_interrupts.end - cpu_enable_interrupts)
cpu_enable_interrupts:
    sti
    ret
.end:

; Read from I/O port (8-bit)
; Parameter: port number in first argument (following calling convention)
global cpu_inb:function (cpu_inb.end - cpu_inb)
cpu_inb:
    push ebp
    mov ebp, esp

    mov edx, [ebp + 8]  ; Get port number from stack
    in al, dx           ; Read byte from port

    pop ebp
    ret
.end:

; Write to I/O port (8-bit)
; Parameters: port number, value
global cpu_outb:function (cpu_outb.end - cpu_outb)
cpu_outb:
    push ebp
    mov ebp, esp

    mov edx, [ebp + 8]  ; Get port number
    mov eax, [ebp + 12] ; Get value
    out dx, al          ; Write byte to port

    pop ebp
    ret
.end:

; Load Interrupt Descriptor Table
; Parameter: pointer to IDT descriptor
global lidt:function (lidt.end - lidt)
lidt:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]  ; Get IDT descriptor pointer from stack
    lidt [eax]          ; Load IDT

    pop ebp
    ret
.end:

; GNU-STACK SECTION
; This section marks the stack as non-executable to satisfy GNU ld requirements
section .note.GNU-stack noalloc noexec nowrite progbits
