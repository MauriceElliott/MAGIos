package core


// VGA text mode constants
VGA_WIDTH :: 80
VGA_HEIGHT :: 25
VGA_MEMORY :: 0xB8000

// VGA color constants
VGA_COLOR_BLACK :: 0
VGA_COLOR_BLUE :: 1
VGA_COLOR_GREEN :: 2
VGA_COLOR_CYAN :: 3
VGA_COLOR_RED :: 4
VGA_COLOR_MAGENTA :: 5
VGA_COLOR_BROWN :: 6
VGA_COLOR_LIGHT_GREY :: 7
VGA_COLOR_DARK_GREY :: 8
VGA_COLOR_LIGHT_BLUE :: 9
VGA_COLOR_LIGHT_GREEN :: 10
VGA_COLOR_LIGHT_CYAN :: 11
VGA_COLOR_LIGHT_RED :: 12
VGA_COLOR_LIGHT_MAGENTA :: 13
VGA_COLOR_LIGHT_BROWN :: 14
VGA_COLOR_WHITE :: 15

// Terminal state
terminal_row: u32 = 0
terminal_column: u32 = 0
terminal_color: u8 = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK)

// VGA buffer pointer - access directly without storing pointer
VGA_BUFFER :: cast(^u16)uintptr(VGA_MEMORY)

// Create a VGA color entry
vga_entry_color :: proc(fg: u8, bg: u8) -> u8 {
	return fg | (bg << 4)
}

// Create a VGA character entry
vga_entry :: proc(uc: u8, color: u8) -> u16 {
	return u16(uc) | (u16(color) << 8)
}

// Set terminal color
terminal_setcolor :: proc(color: u8) {
	terminal_color = color
}

// Put a character at specific position
terminal_putentryat :: proc(c: u8, color: u8, x: u32, y: u32) {
	// Calculate offset manually without using ptr_offset
	offset := uintptr(y * VGA_WIDTH + x)
	ptr := cast(^u16)(uintptr(VGA_BUFFER) + offset * size_of(u16))
	ptr^ = vga_entry(c, color)
}

// Put a character at current position
terminal_putchar :: proc(c: u8) {
	if c == '\n' {
		terminal_column = 0
		terminal_row += 1
		if terminal_row >= VGA_HEIGHT {
			terminal_row = 0
		}
		return
	}

	terminal_putentryat(c, terminal_color, terminal_column, terminal_row)
	terminal_column += 1

	if terminal_column >= VGA_WIDTH {
		terminal_column = 0
		terminal_row += 1
		if terminal_row >= VGA_HEIGHT {
			terminal_row = 0
		}
	}
}

// Write a string to terminal
terminal_write :: proc(data: string) {
	for i in 0 ..< len(data) {
		terminal_putchar(data[i])
	}
}

// Write a null-terminated C string
terminal_write_cstring :: proc(data: cstring) {
	data_ptr := cast(^u8)data
	i := 0
	for {
		char_ptr := cast(^u8)(uintptr(data_ptr) + uintptr(i))
		if char_ptr^ == 0 do break
		terminal_putchar(char_ptr^)
		i += 1
	}
}

// Clear the screen
terminal_clear :: proc() {
	for y in 0 ..< VGA_HEIGHT {
		for x in 0 ..< VGA_WIDTH {
			offset := uintptr(y * VGA_WIDTH + x)
			ptr := cast(^u16)(uintptr(VGA_BUFFER) + offset * size_of(u16))
			ptr^ = vga_entry(' ', terminal_color)
		}
	}
	terminal_row = 0
	terminal_column = 0
}

// MAGI boot sequence display
boot_sequence :: proc() {
	// Clear screen first
	terminal_clear()

	// MAGI System header
	terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK))
	terminal_write("MAGIos Boot Sequence Initiated.\n")
	terminal_write("-------------------------------\n\n")

	// MAGI subsystems status
	terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK))
	terminal_write("CASPER-1 Online...\n")
	terminal_write("MELCHIOR-2 Online...\n")
	terminal_write("BALTHASAR-3 Online...\n\n")

	// Final status
	terminal_setcolor(vga_entry_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK))
	terminal_write("MAGI System nominal.\n")
	terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK))
	terminal_write("God is in his heaven, all is right with the world.\n")

	// Reset to default color
	terminal_setcolor(vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK))
}

// External assembly functions
foreign _ {
	cpu_disable_interrupts :: proc() ---
	cpu_enable_interrupts :: proc() ---
	cpu_halt :: proc() ---
	cpu_halt_forever :: proc() ---
	cpu_inb :: proc(port: u16) -> u8 ---
	cpu_outb :: proc(port: u16, value: u8) ---
}

// Kernel panic handler
kernel_panic :: proc(message: string) {
	// Disable interrupts
	cpu_disable_interrupts()

	// Display panic message
	terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_RED))
	terminal_clear()
	terminal_write("KERNEL PANIC: ")
	terminal_write(message)

	// Halt forever
	cpu_halt_forever()
}

// Main kernel entry point - called from boot.s
@(export)
kernel_main :: proc "c" (magic: u32, mbi_addr: u32) {
	context = {}

	if magic != 0x2BADB002 {
		kernel_panic("Invalid multiboot magic number!")
	}

	// Run boot sequence
	boot_sequence()

	// Initialize Terminal Dispatch
	setup_idt()
	cpu_enable_interrupts()

	// Disable interrupts and halt forever
	cpu_halt_forever()
}

/*
 * === KERNEL DOCUMENTATION ===
 *
 * VGA_TEXT_MODE:
 * Standard VGA text mode at 0xB8000
 * 80x25 characters, 16 colors
 * Each character is 2 bytes: ASCII code + attribute
 *
 * TERMINAL_FUNCTIONS:
 * terminal_setcolor: Change text color
 * terminal_putchar: Output single character
 * terminal_write: Output string
 * terminal_clear: Clear screen
 *
 * KERNEL_ENTRY:
 * kernel_main: Called from assembly bootstrap
 * Receives multiboot magic and info structure
 * Verifies boot environment before proceeding
 *
 * ODIN_SPECIFICS:
 * Uses Odin's built-in types (u8, u16, u32)
 * C calling convention for kernel_main
 * Direct memory access via pointers
 * Inline assembly for CPU functions
 */
