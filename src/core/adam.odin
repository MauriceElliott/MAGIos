package core

UART_BASE :: 0x10000000
UART_THR :: 0 // Transmit Holding Registry Offset
UART_LSR :: 5 // Line Status Register offset

// Terminal state
terminal_row: u32 = 0
terminal_column: u32 = 0
terminal_width: u32 = 100

terminal_write :: proc(data: string) {
	// Direct UART register access
	uart_thr := cast(^u8)(uintptr(UART_BASE + UART_THR))
	uart_lsr := cast(^u8)(uintptr(UART_BASE + UART_LSR))

	for i in 0 ..< len(data) {
		// Wait for transmit holding register to be empty (bit 5 of LSR)
		for (uart_lsr^ & 0x20) == 0 {
			// Busy wait - transmitter not ready
		}

		// Send character and track position
		c := data[i]
		uart_thr^ = c

		// Update cursor tracking
		if c == '\n' {
			terminal_row += 1
			terminal_column = 0
		} else if c == '\r' {
			terminal_column = 0
		} else if c >= 32 { 	// Printable character
			terminal_column += 1
			if terminal_column >= terminal_width {
				uart_thr^ = '\r' // Force carriage return
				uart_thr^ = '\n' // Force newline
				terminal_row += 1
				terminal_column = 0
			}
		}
	}
}

terminal_clear :: proc() {
	// Send enough newlines to clear screen
	for i in 0 ..< 25 {
		terminal_write("\r\n")
	}
	terminal_row = 0
	terminal_column = 0
}


boot_sequence :: proc() {
	//terminal_clear()

	terminal_write("\r\n\r\n")
	terminal_write("=== MAGIos Boot ===\r\n\r\n")

	terminal_write("CASPER-1 Online\r\n")
	terminal_write("MELCHIOR-2 Online\r\n")
	terminal_write("BALTHASAR-3 Online\r\n\r\n")

	terminal_write("MAGI nominal.\r\n")
	terminal_write("All is right.\r\n\r\n")
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
kernel_main :: proc "c" () {
	context = {}

	// Run boot sequence
	boot_sequence()

	// For RISC-V, we'll implement trap handlers instead of x86 IDT
	// TODO: setup_traps()

	terminal_write("KERNEL OK.\r\n")
	terminal_write("MAGI SYNC.\r\n")

	// Keep kernel running
	for {
		cpu_halt() // Halt until interrupt, then continue loop
	}
}
