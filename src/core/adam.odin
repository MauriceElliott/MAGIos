package core

import v "../virtues"

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

	clear_back_buffer()

	draw_string("")
	draw_string("=== MAGIos Boot Sequence Initiated ===")
	draw_string("")

	draw_string("CASPER-1 Online")
	draw_string("MELCHIOR-2 Online")
	draw_string("BALTHASAR-3 Online")

	draw_string("Hello  world!.")

	draw_string("MAGI System nominal.")
	draw_string("God is in his heaven, all is right with the world.")
	draw_string("")

	swap_buffers()
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

	draw_string("KERNEL OK.")
	draw_string("MAGI SYNC.")

	// Keep kernel running
	for {
		if redraw_flag {
			// Perform buffer swap
			swap_buffers()

			// Clear back buffer for next frame
			clear_back_buffer()

			// Reset redraw flag
			redraw_flag = false
		}
		cpu_halt() // Halt until interrupt, then continue loop
	}
}
