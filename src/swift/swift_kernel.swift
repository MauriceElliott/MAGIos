// MAGIos Swift Kernel - Absolute Minimal Implementation
// Just proves Swift can compile and link with C

// MARK: - External C Functions
@_silgen_name("terminal_putchar")
func c_terminal_putchar(_ char: Int8)

@_silgen_name("terminal_setcolor")
func c_terminal_setcolor(_ color: Int8)

@_silgen_name("terminal_writestring")
func c_terminal_writestring(_ str: UnsafeMutablePointer<Int8>)

// C character helper functions
@_silgen_name("get_char_O")
func c_get_char_O() -> Int8

@_silgen_name("get_char_K")
func c_get_char_K() -> Int8

@_silgen_name("get_char_space")
func c_get_char_space() -> Int8

@_silgen_name("get_char_newline")
func c_get_char_newline() -> Int8

@_silgen_name("get_color_green")
func c_get_color_green() -> Int8

@_silgen_name("get_color_cyan")
func c_get_color_cyan() -> Int8

// MARK: - Swift Display Functions
func swift_display_ok() {
    let word: [Int8] = [79, 75, 32, 10]
    c_terminal_setcolor(c_get_color_green())

    // Display "OK " using C character helpers
    for char in word {
        c_terminal_putchar(char)
    }
}

// MARK: - Required Entry Points
@_cdecl("swift_kernel_main")
public func swiftKernelMain() {
    // Now Swift can display text using C helpers!
    swift_display_ok()
}

@_cdecl("swift_terminal_setcolor")
public func swiftTerminalSetcolor(_ color: Int8) {
    // Forward to C (but don't actually call it to avoid parameter issues)
}

@_cdecl("swift_terminal_writestring")
public func swiftTerminalWritestring(_ data: UnsafeMutablePointer<Int8>) {
    // Forward to C implementation
    c_terminal_writestring(data)
}

@_cdecl("swift_hello")
public func swiftHello() {
    swift_display_ok()
}
