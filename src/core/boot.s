; MAGIos Boot Assembly Code - Odin Version
; This file contains the multiboot header and initial kernel entry point
; It sets up the basic environment needed before jumping to Odin code

; === MULTIBOOT SPECIFICATION CONSTANTS ===
; These magic numbers are defined by the Multiboot specification
; GRUB uses these to identify and properly load our kernel
MBALIGN  equ  1 << 0              ; Align loaded modules on page boundaries
MEMINFO  equ  1 << 1              ; Provide memory map to the kernel
FLAGS    equ  MBALIGN | MEMINFO   ; Combine the flags we want
MAGIC    equ  0x1BADB002          ; Magic number that identifies multiboot header
CHECKSUM equ -(MAGIC + FLAGS)     ; Checksum to verify header integrity

; === MULTIBOOT HEADER SECTION ===
; CRITICAL: This section must be within the first 8KB of the kernel binary
; GRUB searches for this header to determine if the file is bootable
section .multiboot
align 4                           ; Align on 4-byte boundary as required by spec
    dd MAGIC                      ; Magic number for multiboot identification
    dd FLAGS                      ; Feature flags we're requesting from bootloader
    dd CHECKSUM                   ; Checksum (magic + flags + checksum = 0)

; === STACK ALLOCATION SECTION ===
; We need to set up a stack before we can call Odin functions
; The BSS section contains uninitialized data (zeroed out at boot)
section .bss
align 16                          ; Align stack on 16-byte boundary (recommended for x86)
stack_bottom:                     ; Label marking the bottom of our stack
resb 16384                        ; Reserve 16KB of space for the stack (16 * 1024 bytes)
stack_top:                        ; Label marking the top of our stack (stacks grow downward)

; === EXECUTABLE CODE SECTION ===
section .text

; === KERNEL ENTRY POINT ===
; CRITICAL: This is where GRUB transfers control after loading the kernel
global _start:function (_start.end - _start)   ; Make '_start' visible to linker, mark as function
_start:
    ; === STACK SETUP ===
    ; CRITICAL: Set up stack pointer before calling any Odin functions
    ; x86 stacks grow downward, so we point to the top of our reserved space
    mov esp, stack_top            ; ESP = stack pointer register, point to top of stack

    ; === PREPARE FOR ODIN CODE ===
    ; At this point we have:
    ; - A valid stack (required for function calls)
    ; - Protected mode enabled (done by GRUB)
    ; - Basic GDT loaded (done by GRUB)
    ; - Multiboot information in registers (EAX = magic, EBX = info structure)

    ; === PRESERVE MULTIBOOT INFO ===
    ; Save multiboot magic number and info pointer before calling Odin
    push ebx                      ; Push multiboot info structure pointer
    push eax                      ; Push magic number

    ; === CALL MAIN KERNEL FUNCTION ===
    ; CRITICAL: Jump to our Odin kernel code
    extern kernel_main            ; Declare external symbol (defined in kernel.odin)
    call kernel_main              ; Call our main kernel function

    ; === INFINITE HALT LOOP ===
    ; CRITICAL: If kernel_main ever returns (which it shouldn't), we need to handle it
    ; We can't return to GRUB, so we halt the CPU
    cli                           ; Clear interrupts (disable interrupt handling)
.hang:                           ; Local label for the infinite loop
    hlt                          ; Halt CPU until next interrupt (saves power)
    jmp .hang                    ; Jump back to halt (in case an NMI wakes us up)
.end:                           ; End marker for function size calculation

; === EXPLANATION OF WHAT HAPPENS DURING BOOT ===
; 1. BIOS loads GRUB from disk
; 2. GRUB reads our kernel file and finds the multiboot header
; 3. GRUB loads our kernel at 0x00100000 (1MB) as specified in linker script
; 4. GRUB switches to protected mode and sets up basic GDT
; 5. GRUB jumps to our '_start' symbol (this code)
; 6. We set up our stack and call kernel_main()
; 7. Our Odin code takes over from there

; === ODIN INTEGRATION NOTES ===
; - The multiboot info is passed on the stack to kernel_main
; - Odin's calling convention is compatible with C
; - Stack must be properly aligned for Odin function calls

; === GNU-STACK SECTION ===
; This section marks the stack as non-executable to satisfy GNU ld requirements
; Without this, the linker warns about missing .note.GNU-stack section
section .note.GNU-stack noalloc noexec nowrite progbits
