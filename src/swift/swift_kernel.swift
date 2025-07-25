// MAGIos Swift Kernel - Absolute Minimal Implementation
// Just proves Swift can compile and link with C

// MARK: - External C Functions
@_silgen_name("terminal_putchar")
func c_terminal_putchar(_ char: Builtin.Int8)

@_silgen_name("terminal_setcolor")
func c_terminal_setcolor(_ color: Builtin.Int8)

@_silgen_name("terminal_writestring")
func c_terminal_writestring(_ str: Builtin.RawPointer)

// C character helper functions
@_silgen_name("get_char_O")
func c_get_char_O() -> Builtin.Int8

@_silgen_name("get_char_K")
func c_get_char_K() -> Builtin.Int8

@_silgen_name("get_char_space")
func c_get_char_space() -> Builtin.Int8

@_silgen_name("get_char_newline")
func c_get_char_newline() -> Builtin.Int8

@_silgen_name("get_color_green")
func c_get_color_green() -> Builtin.Int8

@_silgen_name("get_color_cyan")
func c_get_color_cyan() -> Builtin.Int8

// MARK: - Swift Display Functions
func swift_display_ok() {
    // Set color to green using C helper
    c_terminal_setcolor(c_get_color_green())

    // Display "OK " using C character helpers
    c_terminal_putchar(c_get_char_O())
    c_terminal_putchar(c_get_char_K())
    c_terminal_putchar(c_get_char_space())
    c_terminal_putchar(c_get_char_newline())
}

// MARK: - Required Entry Points
@_cdecl("swift_kernel_main")
public func swiftKernelMain() {
    // Now Swift can display text using C helpers!
    swift_display_ok()
}

@_cdecl("swift_terminal_setcolor")
public func swiftTerminalSetcolor(_ color: Builtin.Int8) {
    // Forward to C (but don't actually call it to avoid parameter issues)
}

@_cdecl("swift_terminal_writestring")
public func swiftTerminalWritestring(_ data: Builtin.RawPointer) {
    // Forward to C implementation
    c_terminal_writestring(data)
}

@_cdecl("swift_hello")
public func swiftHello() {
    swift_display_ok()
}
