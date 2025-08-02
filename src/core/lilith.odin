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
	cpu_inb :: proc(port: u16) -> u8 ---
	cpu_outb :: proc(port: u16, value: u8) ---
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

	// Load Interrupt Descriptor Table first
	lidt(&idt_instance.idt_ptr)
	terminal_write("IDT LOADED.\n")

	// Initialize PIC
	init_pic()
	terminal_write("PIC INITIALIZED.\n")

	// Initialize keyboard controller
	init_keyboard()
	terminal_write("KEYBOARD INITIALIZED.\n")
}

//add interrupt entry to the IDT
idt_set_gate :: proc(num: int, base: u32, sel: u16, flags: u8) {
	idt_instance.entries[num].offset_low = u16(base & 0xFFFF)
	idt_instance.entries[num].selector = sel
	idt_instance.entries[num].zero = 0
	idt_instance.entries[num].type_attr = flags
	idt_instance.entries[num].offset_high = u16((base >> 16) & 0xFFFF)
}

init_pic :: proc() {
	// ICW1: Initialize PIC
	cpu_outb(0x20, 0x11) // Master PIC command
	cpu_outb(0xA0, 0x11) // Slave PIC command

	// ICW2: Remap interrupts
	cpu_outb(0x21, 0x20) // Master PIC starts at interrupt 32
	cpu_outb(0xA1, 0x28) // Slave PIC starts at interrupt 40

	// ICW3: Setup cascade
	cpu_outb(0x21, 0x04) // Master PIC has slave at IRQ2
	cpu_outb(0xA1, 0x02) // Slave PIC cascade identity

	// ICW4: Environment info
	cpu_outb(0x21, 0x01) // 8086 mode
	cpu_outb(0xA1, 0x01) // 8086 mode

	// Unmask keyboard interrupt (IRQ 1)
	cpu_outb(0x21, 0xFD) // Enable only keyboard interrupt
	cpu_outb(0xA1, 0xFF) // Disable all slave PIC interrupts
}

init_keyboard :: proc() {
	// Clear keyboard buffer
	terminal_write("DEBUG1: Clearing keyboard buffer...\n")
	for {
		status := cpu_inb(0x64)
		if (status & 0x01) == 0 do break // No data available
		cpu_inb(0x60) // Read and discard
	}
	terminal_write("DEBUG2: Buffer cleared.\n")

	// Enable keyboard
	terminal_write("DEBUG3: Enabling keyboard...\n")
	for {
		status := cpu_inb(0x64)
		if (status & 0x02) == 0 do break // Input buffer empty
	}
	cpu_outb(0x64, 0xAE) // Enable keyboard command
	terminal_write("DEBUG4: Keyboard enabled.\n")

	// Simple test: read keyboard status
	status := cpu_inb(0x64)
	terminal_write("DEBUG5: Keyboard status after enable: ")
	terminal_write(eliquence.stringify(status))
	terminal_write("\n")

	terminal_write("DEBUG6: Keyboard initialization complete.\n")
}

@(export)
//Remember to add the proc "c" bit so this becomes available not only in c but also in assembly
terminal_dispatch :: proc "c" (interrupt_number: int) {
	context = {}
	terminal_write("ALL ABOARD TERMINAL DISPATCH!.\n")

	switch interrupt_number {
	case 33:
		sync_keyboard()
	case:
		// Create the error message manually for now
		terminal_write(
			eliquence.coal("Unhandled interrupt\n", eliquence.stringify(interrupt_number)),
		)
		cpu_halt_forever()
	}
}

sync_keyboard :: proc() {
	scancode := cpu_inb(0x60)

	terminal_setcolor(vga_entry_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK))
	terminal_write(eliquence.stringify(scancode))
}
