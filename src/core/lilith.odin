package core

import "../virtues"
import "base:runtime"

// Remove IDTEntry, IDT_PTR, IDT structs
// Add RISC-V trap frame:

TrapFrame :: struct {
	// General-purpose registers x1-x31 (x0 is always 0)
	ra:     u64, // x1 - Return address
	sp:     u64, // x2 - Stack pointer
	gp:     u64, // x3 - Global pointer
	tp:     u64, // x4 - Thread pointer
	t0:     u64, // x5 - Temporary
	t1:     u64, // x6 - Temporary
	t2:     u64, // x7 - Temporary
	s0:     u64, // x8 - Saved register / Frame pointer
	s1:     u64, // x9 - Saved register
	a0:     u64, // x10 - Function argument / return value
	a1:     u64, // x11 - Function argument / return value
	a2:     u64, // x12 - Function argument
	a3:     u64, // x13 - Function argument
	a4:     u64, // x14 - Function argument
	a5:     u64, // x15 - Function argument
	a6:     u64, // x16 - Function argument
	a7:     u64, // x17 - Function argument
	s2:     u64, // x18 - Saved register
	s3:     u64, // x19 - Saved register
	s4:     u64, // x20 - Saved register
	s5:     u64, // x21 - Saved register
	s6:     u64, // x22 - Saved register
	s7:     u64, // x23 - Saved register
	s8:     u64, // x24 - Saved register
	s9:     u64, // x25 - Saved register
	s10:    u64, // x26 - Saved register
	s11:    u64, // x27 - Saved register
	t3:     u64, // x28 - Temporary
	t4:     u64, // x29 - Temporary
	t5:     u64, // x30 - Temporary
	t6:     u64, // x31 - Temporary

	// Special registers
	pc:     u64, // Program counter (mepc)
	cause:  u64, // Trap cause (mcause)
	tval:   u64, // Trap value (mtval)
	status: u64, // Status register (mstatus)
}

// Timer interrupt setup
CLINT_BASE :: 0x02000000
CLINT_MTIME :: CLINT_BASE + 0xBFF8
CLINT_MTIMECMP :: CLINT_BASE + 0x4000

setup_traps :: proc() {
	terminal_write("Setting up RISC-V trap system...\n")

	// Set trap vector (mtvec) to our trap handler
	// Will be implemented in interrupts.s
	set_trap_vector()

	// Enable timer interrupts
	enable_timer_interrupts()

	//Initialize display hardware
	setup_virtio_gpu()

	terminal_write("RISC-V Trap System Initialized.\n")
}

// These will be implemented as foreign functions
foreign _ {
	set_trap_vector :: proc() ---
	enable_timer_interrupts :: proc() ---
	get_time :: proc() -> u64 ---
	set_timer :: proc(time: u64) ---
}

@(export)
trap_handler :: proc "c" (frame: ^TrapFrame) {
	context = runtime.default_context()

	cause := frame.cause

	// Check if it's an interrupt (MSB set) or exception
	if (cause & (1 << 63)) != 0 {
		// Interrupt
		interrupt_cause := cause & 0x7FFFFFFFFFFFFFFF
		switch interrupt_cause {
		case 7:
			// Timer interrupt
			handle_timer_interrupt()
		case:
			terminal_write("Unknown interrupt: ")
			terminal_write(virtues.stringify(interrupt_cause))
			terminal_write("\n")
		}
	} else {
		// Exception
		terminal_write("Exception occurred: ")
		terminal_write(virtues.stringify(cause))
		terminal_write(" at PC: ")
		terminal_write(virtues.stringify(frame.pc))
		terminal_write("\n")
		// Halt on exceptions for now
		for {
			cpu_halt()
		}
	}
}

frame_count: u64 = 0

handle_timer_interrupt :: proc() {
	// Set next timer interrupt for 60 FPS
	current_time := get_time()
	next_time := current_time + 166700 // 16.67ms at 10MHz for 60 FPS
	set_timer(next_time)

	// Set redraw flag for buffer swap
	redraw_flag = true

	frame_count += 1
	if frame_count % 60 == 0 {
		terminal_write("60 frames rendered\n")
	}
}

//VIRTIO GPU Setup
VIRTIO_GPU_BASE :: 0x10008000

setup_virtio_gpu :: proc() {
	terminal_write("Initializing VirtIO GPU \n")

	gpu_base := cast(^u32)(uintptr(VIRTIO_GPU_BASE))
	device_id := cpu_read_mmio_32(uintptr(VIRTIO_GPU_BASE + 0x08))

	terminal_write("VirtIO GPU device ID: ")
	terminal_write(virtues.stringify(u64(device_id)))
	terminal_write("\n")

	if device_id == 0x1050 {
		terminal_write("VirtIO GPU detected\n")
		terminal_write("Framebuffer mode: 640x480x32\n")
	} else {
		terminal_write("VirtIO GPU not available (expected 0x1050, got ")
		terminal_write(virtues.stringify(u64(device_id)))
		terminal_write(")\n")
	}
}
