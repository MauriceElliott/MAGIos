section .text

extern terminal_dispatch

global isr_stub_0:function (isr_stub_0.end - isr_stub_0)
isr_stub_0:
        pusha
        push 0
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_1:function (isr_stub_1.end - isr_stub_1)
isr_stub_1:
        pusha
        push 1
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_2:function (isr_stub_2.end - isr_stub_2)
isr_stub_2:
        pusha
        push 2
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_3:function (isr_stub_3.end - isr_stub_3)
isr_stub_3:
    mov word [0xB8000], 0x0F4B  ; Write 'K' in white on black at top-left
    in al, 0x60                 ; Read scancode to clear buffer
    mov al, 0x20
    out 0x20, al                ; Send EOI to PIC
    iret
.end:

global isr_stub_4:function (isr_stub_4.end - isr_stub_4)
isr_stub_4:
        pusha
        push 4
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_5:function (isr_stub_5.end - isr_stub_5)
isr_stub_5:
        pusha
        push 5
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_6:function (isr_stub_6.end - isr_stub_6)
isr_stub_6:
        pusha
        push 6
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_7:function (isr_stub_7.end - isr_stub_7)
isr_stub_7:
        pusha
        push 7
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_8:function (isr_stub_8.end - isr_stub_8)
isr_stub_8:
        pusha
        push 8
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_9:function (isr_stub_9.end - isr_stub_9)
isr_stub_9:
        pusha
        push 9
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_10:function (isr_stub_10.end - isr_stub_10)
isr_stub_10:
        pusha
        push 10
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_11:function (isr_stub_11.end - isr_stub_11)
isr_stub_11:
        pusha
        push 11
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_12:function (isr_stub_12.end - isr_stub_12)
isr_stub_12:
        pusha
        push 12
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_13:function (isr_stub_13.end - isr_stub_13)
isr_stub_13:
        pusha
        push 13
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_14:function (isr_stub_14.end - isr_stub_14)
isr_stub_14:
        pusha
        push 14
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_15:function (isr_stub_15.end - isr_stub_15)
isr_stub_15:
        pusha
        push 15
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_16:function (isr_stub_16.end - isr_stub_16)
isr_stub_16:
        pusha
        push 16
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_17:function (isr_stub_17.end - isr_stub_17)
isr_stub_17:
        pusha
        push 17
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_18:function (isr_stub_18.end - isr_stub_18)
isr_stub_18:
        pusha
        push 18
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_19:function (isr_stub_19.end - isr_stub_19)
isr_stub_19:
        pusha
        push 19
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_20:function (isr_stub_20.end - isr_stub_20)
isr_stub_20:
        pusha
        push 20
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_21:function (isr_stub_21.end - isr_stub_21)
isr_stub_21:
        pusha
        push 21
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_22:function (isr_stub_22.end - isr_stub_22)
isr_stub_22:
        pusha
        push 22
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_23:function (isr_stub_23.end - isr_stub_23)
isr_stub_23:
        pusha
        push 23
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_24:function (isr_stub_24.end - isr_stub_24)
isr_stub_24:
        pusha
        push 24
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_25:function (isr_stub_25.end - isr_stub_25)
isr_stub_25:
        pusha
        push 25
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_26:function (isr_stub_26.end - isr_stub_26)
isr_stub_26:
        pusha
        push 26
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_27:function (isr_stub_27.end - isr_stub_27)
isr_stub_27:
        pusha
        push 27
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_28:function (isr_stub_28.end - isr_stub_28)
isr_stub_28:
        pusha
        push 28
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_29:function (isr_stub_29.end - isr_stub_29)
isr_stub_29:
        pusha
        push 29
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_30:function (isr_stub_30.end - isr_stub_30)
isr_stub_30:
        pusha
        push 30
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_31:function (isr_stub_31.end - isr_stub_31)
isr_stub_31:
        pusha
        push 31
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_32:function (isr_stub_32.end - isr_stub_32)
isr_stub_32:
        pusha
        push 32
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

global isr_stub_33:function (isr_stub_33.end - isr_stub_33)
isr_stub_33:
        pusha
        push 33
        call terminal_dispatch
        add esp, 4
        popa
        iret
.end:

; GNU-STACK SECTION
; This section marks the stack as non-executable to satisfy GNU ld requirements
section .note.GNU-stack noalloc noexec nowrite progbits
