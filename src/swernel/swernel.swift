/*
 * MAGIos Swift Kernel (Swernel) - MAGI System Core
 * Swift-first kernel implementation with Evangelion aesthetic
 * Part of the Terminal Dogma operating system
 */

// === PATH CONSTANTS ===
// Centralized path references for easier maintenance
// Note: Swift kernel (swernel) is located at src/swernel/
// C kernel bridge is at src/kernel/include/kernel_bridge.h

// === MAGI SYSTEM CONFIGURATION ===
// CASPER: Character display subsystem
// MELCHIOR: Memory management (future)
// BALTHASAR: Boot coordination (future)

// === C BRIDGE FUNCTIONS ===
// External C wrapper functions we can call (no parameters needed)
// These provide hardware abstraction from the C kernel layer
@_silgen_name("swift_putchar_h")
func c_putchar_h()

@_silgen_name("swift_putchar_e")
func c_putchar_e()

@_silgen_name("swift_putchar_l")
func c_putchar_l()

@_silgen_name("swift_putchar_o")
func c_putchar_o()

@_silgen_name("swift_putchar_comma")
func c_putchar_comma()

@_silgen_name("swift_putchar_space")
func c_putchar_space()

@_silgen_name("swift_putchar_f")
func c_putchar_f()

@_silgen_name("swift_putchar_r")
func c_putchar_r()

@_silgen_name("swift_putchar_m")
func c_putchar_m()

@_silgen_name("swift_putchar_s")
func c_putchar_s()

@_silgen_name("swift_putchar_w")
func c_putchar_w()

@_silgen_name("swift_putchar_i")
func c_putchar_i()

@_silgen_name("swift_putchar_t")
func c_putchar_t()

@_silgen_name("swift_putchar_exclamation")
func c_putchar_exclamation()

@_silgen_name("swift_putchar_newline")
func c_putchar_newline()

@_silgen_name("swift_set_color_yellow")
func c_set_color_yellow()

// === SWIFT KERNEL FUNCTIONS ===
// MAGI CASPER subsystem - character display

// Swift message display function
func swift_display_hello() {
    // Set color to yellow
    c_set_color_yellow()

    // Display "hello, from swift!"
    c_putchar_h()
    c_putchar_e()
    c_putchar_l()
    c_putchar_l()
    c_putchar_o()
    c_putchar_comma()
    c_putchar_space()
    c_putchar_f()
    c_putchar_r()
    c_putchar_o()
    c_putchar_m()
    c_putchar_space()
    c_putchar_s()
    c_putchar_w()
    c_putchar_i()
    c_putchar_f()
    c_putchar_t()
    c_putchar_exclamation()
    c_putchar_newline()
}

// === KERNEL ENTRY POINTS ===
// Main Swift kernel initialization - called from C bootstrap

// Entry point function - called from C
@_cdecl("swift_kernel_main")
func swiftKernelMain() {
    // Display our Swift message!
    swift_display_hello()
}

// === DEVELOPMENT FUNCTIONS ===
// Functions for testing and debugging the Swift kernel

// Test function that returns nothing
@_cdecl("swift_hello")
func swiftHello() {
    swift_display_hello()
}

// Simple function for testing
@_cdecl("swift_test")
func swiftTest() {
    // Minimal test function
}

// === C COMPATIBILITY LAYER ===
// Required functions that C code expects
// These maintain compatibility with the C kernel bridge
@_cdecl("swift_terminal_setcolor")
func swiftTerminalSetcolor() {
    // Minimal implementation - does nothing
}

@_cdecl("swift_terminal_writestring")
func swiftTerminalWritestring() {
    // Minimal implementation - does nothing
}
