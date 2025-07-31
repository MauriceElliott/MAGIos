package core

import eliquence "../virtues"

foreign _ {
	isr_stub_0 :: proc() ---
	isr_stub_1 :: proc() ---
	isr_stub_2 :: proc() ---
	isr_stub_3 :: proc() ---
	isr_stub_4 :: proc() ---
	isr_stub_5 :: proc() ---
	isr_stub_6 :: proc() ---
	isr_stub_7 :: proc() ---
	isr_stub_8 :: proc() ---
	isr_stub_9 :: proc() ---
	isr_stub_10 :: proc() ---
	isr_stub_11 :: proc() ---
	isr_stub_12 :: proc() ---
	isr_stub_13 :: proc() ---
	isr_stub_14 :: proc() ---
	isr_stub_15 :: proc() ---
	isr_stub_16 :: proc() ---
	isr_stub_17 :: proc() ---
	isr_stub_18 :: proc() ---
	isr_stub_19 :: proc() ---
	isr_stub_20 :: proc() ---
	isr_stub_21 :: proc() ---
	isr_stub_22 :: proc() ---
	isr_stub_23 :: proc() ---
	isr_stub_24 :: proc() ---
	isr_stub_25 :: proc() ---
	isr_stub_26 :: proc() ---
	isr_stub_27 :: proc() ---
	isr_stub_28 :: proc() ---
	isr_stub_29 :: proc() ---
	isr_stub_30 :: proc() ---
	isr_stub_31 :: proc() ---
	isr_stub_32 :: proc() ---
	isr_stub_33 :: proc() ---
	lidt :: proc(ptr: rawptr) ---
}

IDTEntry :: struct {
	offset_low:  u16,
	selector:    u16,
	zero:        u8,
	type_attr:   u8,
	offset_high: u16,
}

IDT_PTR :: struct {
	limit: u16,
	base:  u32,
}

IDT :: struct {
	entries: [256]IDTEntry,
	idt_ptr: IDT_PTR,
}

idt_instance: IDT

// 0-31 interrupts are reserved for CPU exceptions
// 32 is for a timer interrupt
// 33 is for a keyboard interrupt
// 34-255 interrupts are reserved for device interrupts, but are not yet used
setup_idt :: proc() {
	idt_set_gate(0, cast(u32)cast(uintptr)cast(rawptr)isr_stub_0, 0x08, 0x8E)
	idt_set_gate(1, cast(u32)cast(uintptr)cast(rawptr)isr_stub_1, 0x08, 0x8E)
	idt_set_gate(2, cast(u32)cast(uintptr)cast(rawptr)isr_stub_2, 0x08, 0x8E)
	idt_set_gate(3, cast(u32)cast(uintptr)cast(rawptr)isr_stub_3, 0x08, 0x8E)
	idt_set_gate(4, cast(u32)cast(uintptr)cast(rawptr)isr_stub_4, 0x08, 0x8E)
	idt_set_gate(5, cast(u32)cast(uintptr)cast(rawptr)isr_stub_5, 0x08, 0x8E)
	idt_set_gate(6, cast(u32)cast(uintptr)cast(rawptr)isr_stub_6, 0x08, 0x8E)
	idt_set_gate(7, cast(u32)cast(uintptr)cast(rawptr)isr_stub_7, 0x08, 0x8E)
	idt_set_gate(8, cast(u32)cast(uintptr)cast(rawptr)isr_stub_8, 0x08, 0x8E)
	idt_set_gate(9, cast(u32)cast(uintptr)cast(rawptr)isr_stub_9, 0x08, 0x8E)
	idt_set_gate(10, cast(u32)cast(uintptr)cast(rawptr)isr_stub_10, 0x08, 0x8E)
	idt_set_gate(11, cast(u32)cast(uintptr)cast(rawptr)isr_stub_11, 0x08, 0x8E)
	idt_set_gate(12, cast(u32)cast(uintptr)cast(rawptr)isr_stub_12, 0x08, 0x8E)
	idt_set_gate(13, cast(u32)cast(uintptr)cast(rawptr)isr_stub_13, 0x08, 0x8E)
	idt_set_gate(14, cast(u32)cast(uintptr)cast(rawptr)isr_stub_14, 0x08, 0x8E)
	idt_set_gate(15, cast(u32)cast(uintptr)cast(rawptr)isr_stub_15, 0x08, 0x8E)
	idt_set_gate(16, cast(u32)cast(uintptr)cast(rawptr)isr_stub_16, 0x08, 0x8E)
	idt_set_gate(17, cast(u32)cast(uintptr)cast(rawptr)isr_stub_17, 0x08, 0x8E)
	idt_set_gate(18, cast(u32)cast(uintptr)cast(rawptr)isr_stub_18, 0x08, 0x8E)
	idt_set_gate(19, cast(u32)cast(uintptr)cast(rawptr)isr_stub_19, 0x08, 0x8E)
	idt_set_gate(20, cast(u32)cast(uintptr)cast(rawptr)isr_stub_20, 0x08, 0x8E)
	idt_set_gate(21, cast(u32)cast(uintptr)cast(rawptr)isr_stub_21, 0x08, 0x8E)
	idt_set_gate(22, cast(u32)cast(uintptr)cast(rawptr)isr_stub_22, 0x08, 0x8E)
	idt_set_gate(23, cast(u32)cast(uintptr)cast(rawptr)isr_stub_23, 0x08, 0x8E)
	idt_set_gate(24, cast(u32)cast(uintptr)cast(rawptr)isr_stub_24, 0x08, 0x8E)
	idt_set_gate(25, cast(u32)cast(uintptr)cast(rawptr)isr_stub_25, 0x08, 0x8E)
	idt_set_gate(26, cast(u32)cast(uintptr)cast(rawptr)isr_stub_26, 0x08, 0x8E)
	idt_set_gate(27, cast(u32)cast(uintptr)cast(rawptr)isr_stub_27, 0x08, 0x8E)
	idt_set_gate(28, cast(u32)cast(uintptr)cast(rawptr)isr_stub_28, 0x08, 0x8E)
	idt_set_gate(29, cast(u32)cast(uintptr)cast(rawptr)isr_stub_29, 0x08, 0x8E)
	idt_set_gate(30, cast(u32)cast(uintptr)cast(rawptr)isr_stub_30, 0x08, 0x8E)
	idt_set_gate(31, cast(u32)cast(uintptr)cast(rawptr)isr_stub_31, 0x08, 0x8E)
	idt_set_gate(32, cast(u32)cast(uintptr)cast(rawptr)isr_stub_32, 0x08, 0x8E)
	idt_set_gate(33, cast(u32)cast(uintptr)cast(rawptr)isr_stub_33, 0x08, 0x8E)

	idt_instance.idt_ptr.limit = u16(size_of(idt_instance.entries) - 1)
	idt_instance.idt_ptr.base = cast(u32)cast(uintptr)&idt_instance.entries

	// Load Interrupt Descriptor Table
	lidt(&idt_instance.idt_ptr)
}

//add interrupt entry to the IDT
idt_set_gate :: proc(num: int, base: u32, sel: u16, flags: u8) {
	idt_instance.entries[num].offset_low = u16(base & 0xFFFF)
	idt_instance.entries[num].selector = sel
	idt_instance.entries[num].zero = 0
	idt_instance.entries[num].type_attr = flags
	idt_instance.entries[num].offset_high = u16((base >> 16) & 0xFFFF)
}

@(export)
//Remember to add the proc "c" bit so this becomes available not only in c but also in assembly
terminal_dispatch :: proc "c" (interrupt_number: int) {
	context = {}
	switch interrupt_number {
	case 33:
		sync_keyboard()
	case:
		// Create the error message manually for now
		terminal_write(
			eliquence.concat("Unhandled interrupt\n", eliquence.int_to_string(interrupt_number)),
		)
		cpu_halt_forever()
	}
}

sync_keyboard :: proc() {
	// Read from keyboard port, decode, etc.
	kernel_panic("HELLO!")
}
