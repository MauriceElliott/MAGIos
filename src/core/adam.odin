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

terminal_clear :: proc() {
	terminal_write("\x1b[2J\x1b[H")
}

// Set terminal color
terminal_setcolor :: proc(color: string) {
	terminal_color = color
}


boot_sequence :: proc() {
	terminal_clear()

	// MAGI System header with ANSI colors
	terminal_setcolor(ANSI_CYAN)
	terminal_write("\n\n\n\n")
	terminal_write("--------------------------------------\n\n")
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
kernel_main :: proc "c" () {
	context = {}

	// Run boot sequence
	boot_sequence()

	// For RISC-V, we'll implement trap handlers instead of x86 IDT
	// TODO: setup_traps()

	terminal_write("RISC-V KERNEL OPERATIONAL.\n")
	terminal_write("MAGI systems synchronized.\n")

	// Keep kernel running
	for {
		cpu_halt() // Halt until interrupt, then continue loop
	}
}
