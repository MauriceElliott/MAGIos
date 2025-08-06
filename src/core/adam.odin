package core

UART_BASE :: 0x10000000
UART_THR :: 0 // Transmit Holding Registry Offset
UART_LSR :: 5 // Line Status Register offset


terminal_write :: proc(data: string) {
	// Direct UART register access
	uart_thr := cast(^u8)(uintptr(UART_BASE + UART_THR))
	uart_lsr := cast(^u8)(uintptr(UART_BASE + UART_LSR))

	for i in 0 ..< len(data) {
		// Wait for transmit holding register to be empty (bit 5 of LSR)
		for (uart_lsr^ & 0x20) == 0 {
			// Busy wait - transmitter not ready
		}

		// Send character
		uart_thr^ = data[i]
	}
}

terminal_println :: proc(text: string) {
	terminal_write(text)
	terminal_write("\r\n")
}

terminal_clear :: proc() {
	// Clear screen and reset cursor to top-left
	terminal_write("\x1b[2J\x1b[H")
}


boot_sequence :: proc() {
	terminal_clear()

	terminal_println("")
	terminal_println("=== MAGIos Boot Sequence Initiated ===")
	terminal_println("")

	terminal_println("CASPER-1 Online")
	terminal_println("MELCHIOR-2 Online")
	terminal_println("BALTHASAR-3 Online")
	terminal_println("")

	terminal_println("MAGI System nominal.")
	terminal_println("God is in his heaven, all is right with the world.")
	terminal_println("")
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
	setup_traps()

	terminal_println("KERNEL OK.")
	terminal_println("MAGI SYNC.")

	// Keep kernel running
	for {
		cpu_halt() // Halt until interrupt, then continue loop
	}
}
