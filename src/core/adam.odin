package core

UART_BASE :: 0x10000000
UART_THR :: 0 // Transmit Holding Registry Offset
UART_LSR :: 5 // Line Status Register offset

// Remove VGA color constants, replace with ANSI escape codes
ANSI_RESET :: "\x1b[0m"
ANSI_BLACK :: "\x1b[30m"
ANSI_RED :: "\x1b[31m"
ANSI_GREEN :: "\x1b[32m"
ANSI_YELLOW :: "\x1b[33m"
ANSI_BLUE :: "\x1b[34m"
ANSI_MAGENTA :: "\x1b[35m"
ANSI_CYAN :: "\x1b[36m"
ANSI_WHITE :: "\x1b[37m"

// Terminal state
terminal_row: u32 = 0
terminal_column: u32 = 0
terminal_color: string = ANSI_WHITE

uart_write_char :: proc(char: u8) {
	uart_base := cast(^u8)(uintptr(UART_BASE))
	// wait for transmit ready
	for {
		lsr := cast(^u8)(uintptr(UART_BASE) + UART_LSR)
		if lsr^ & 0x20 != 0 do break
	}
	// Send Character
	thr := cast(^u8)(uintptr(UART_BASE) + UART_THR)
	thr^ = char
}

terminal_putchar :: proc(char: u8) {
	uart_write_char(char)
}

terminal_write :: proc(data: string) {
	for i in 0 ..< len(data) {
		terminal_putchar(data[i])
	}
}

terminal_clear :: proc() {
	terminal_write("\x1b[2J\x1b[H")
}

// Set terminal color
terminal_setcolor :: proc(color: string) {
	terminal_color = color
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

boot_sequence :: proc() {
	terminal_clear()

	// MAGI System header with ANSI colors
	terminal_setcolor(ANSI_CYAN)
	terminal_write("MAGIos RISC-V Boot Sequence Initiated.\n")
	terminal_write("--------------------------------------\n\n")

	// MAGI subsystems status
	terminal_setcolor(ANSI_GREEN)
	terminal_write("CASPER-1 Online... (RISC-V RV64GC)\n")
	terminal_write("MELCHIOR-2 Online... (Virtual Memory)\n")
	terminal_write("BALTHASAR-3 Online... (Trap System)\n\n")

	// Final status
	terminal_setcolor(ANSI_RED)
	terminal_write("MAGI System nominal.\n")
	terminal_write("God is in his heaven, all is right with the world.\n")

	terminal_setcolor(ANSI_RESET)
}

foreign _ {
	cpu_disable_interrupts :: proc() ---
	cpu_enable_interrupts :: proc() ---
	cpu_halt :: proc() ---
	cpu_halt_forever :: proc() ---
	cpu_read_mmio_8 :: proc(addr: uintptr) -> u8 ---
	cpu_write_mmio_8 :: proc(addr: uintptr, value: u8) ---
	cpu_read_mmio_32 :: proc(addr: uintptr) -> u32 ---
	cpu_write_mmio_32 :: proc(addr: uintptr, value: u32) ---
	cpu_read_mmio_64 :: proc(addr: uintptr) -> u64 ---
	cpu_write_mmio_64 :: proc(addr: uintptr, value: u64) ---
	crash :: proc() ---
	cpu_fence :: proc() ---
	cpu_fence_i :: proc() ---
}

// Kernel panic handler
kernel_panic :: proc(message: string) {
	// Disable interrupts
	cpu_disable_interrupts()

	// Display panic message
	terminal_clear()
	terminal_write("KERNEL PANIC: ")
	terminal_write(message)

	// Halt forever
	// cpu_halt_forever()
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
	// setup_idt()
	cpu_enable_interrupts()

	terminal_write("INTERRUPTS ENABLED.\n")
	terminal_write("Waiting for keyboard input...\n")

	// Keep kernel running to receive keyboard interrupts
	for {
		cpu_halt() // Halt until interrupt, then continue loop
	}
}
