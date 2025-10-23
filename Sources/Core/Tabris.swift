// Tabris is the last...except for us
// Maurice Elliott 20251002
// This is the NERVous System that send the messages round the MAGI.

public struct TrapFrame {
	// General-purpose registers x1-x31 (x0 is always 0)
	let ra:     UInt64 // x1 - Return address
	let sp:     UInt64 // x2 - Stack pointer
	let gp:     UInt64 // x3 - Global pointer
	let tp:     UInt64 // x4 - Thread pointer
	let t0:     UInt64 // x5 - Temporary
	let t1:     UInt64 // x6 - Temporary
	let t2:     UInt64 // x7 - Temporary
	let s0:     UInt64 // x8 - Saved register / Frame pointer
	let s1:     UInt64 // x9 - Saved register
	let a0:     UInt64 // x10 - Function argument / return value
	let a1:     UInt64 // x11 - Function argument / return value
	let a2:     UInt64 // x12 - Function argument
	let a3:     UInt64 // x13 - Function argument
	let a4:     UInt64 // x14 - Function argument
	let a5:     UInt64 // x15 - Function argument
	let a6:     UInt64 // x16 - Function argument
	let a7:     UInt64 // x17 - Function argument
	let s2:     UInt64 // x18 - Saved register
	let s3:     UInt64 // x19 - Saved register
	let s4:     UInt64 // x20 - Saved register
	let s5:     UInt64 // x21 - Saved register
	let s6:     UInt64 // x22 - Saved register
	let s7:     UInt64 // x23 - Saved register
	let s8:     UInt64 // x24 - Saved register
	let s9:     UInt64 // x25 - Saved register
	let s10:    UInt64 // x26 - Saved register
	let s11:    UInt64 // x27 - Saved register
	let t3:     UInt64 // x28 - Temporary
	let t4:     UInt64 // x29 - Temporary
	let t5:     UInt64 // x30 - Temporary
	let t6:     UInt64 // x31 - Temporary

	// Special registers
	let pc:     UInt64 // Program counter (mepc)
	let cause:  UInt64 // Trap cause (mcause)
	let tval:   UInt64 // Trap value (mtval)
	let status: UInt64 // Status register (mstatus)
}

final class CallbackHandlerRegistry {
	public var timerHandler: (() -> Void)?
	public var externalHandler: (() -> Void)?
	public var timerTickCount: UInt64 = 0
}

// Timer interrupt setup
let CLINT_BASE = 0x02000000
let CLINT_MTIME = CLINT_BASE + 0xBFF8
let CLINT_MTIMECMP = CLINT_BASE + 0x4000

@_silgen_name("set_trap_vector")
private func asmSetTrapVector()
@_silgen_name("enable_timer_interrupts")
private func asmEnableTimerInterrupts()
@_silgen_name("get_time")
private func asmGetTime() -> Int
@_silgen_name("set_timer")
private func asmSetTimer(_ ticks: Int)
@_silgen_name("trap_vector")
private func asmTrapVector()


let isAnInterruptAddr: UInt64 = 0x8000000000000000
let causeCodeAddr: UInt64 = 0x7FFFFFFFFFFFFFFF

@_cdecl("trap_handler")
public func trapHandler(_ framePtr: UnsafeMutableRawPointer) {
	let frame = framePtr.assumingMemoryBound(to: TrapFrame.self).pointee

	// Check that the passed frame is actually an interrupt
	// Extract interrupt bit 63 and cause code (62-0)
	let isInterrupt = (frame.cause & isAnInterruptAddr) != 0
	let causeCode = frame.cause & causeCodeAddr

	if isInterrupt {
		switch causeCode {
			case 5: //Timer interrupt
				if let handler = CallbackHandlerRegistry().timerHandler {
					handler()
				}
			case 9: //External interrupt (PLIC)
				if let handler = CallbackHandlerRegistry().externalHandler {
					handler()
				}
			default: uartPrint("UnkownInterrupt: ")
		}
	} else {
		uartPrint("Possible exception thrown.")
	}
}

let TIMER_INTERVAL = 10000000 //10ms

private func timerInterruptHandler() {
	CallbackHandlerRegistry().timerTickCount += 1

	if CallbackHandlerRegistry().timerTickCount % 100 == 0 {
		uartPrint("tick tock")
	}

	let currentTime = asmGetTime()
	let nextTime = currentTime + TIMER_INTERVAL
	asmSetTimer(nextTime)
}

private func initTimerHandler() {
	uartPrint("Initialise Timer Handlers")
}

public func setTraps() {
	uartPrint("Setting Traps\n")

	//Installing the trap vector which points the CPU to the trap vector assembly.
	asmSetTrapVector()
	uartPrint("Trap vector set\n")

	//Enable timer interrupts and global interrupts. From this point onwards we scramble to get this system under control.
	asmEnableTimerInterrupts()
	uartPrint("Enabled Timer Interrupts\n")

	//Initialise the Timer Interrupt handler at 10ms (100hz) to make the system a little more manageable.
	initTimerHandler()
	uartPrint("Timer handler initialised.\n")
}
