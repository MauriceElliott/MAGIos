/*
 * MAGIos Swift Kernel - Production Embedded Swift Implementation
 * Evangelion-themed operating system kernel with Embedded Swift
 * Provides VGA terminal management and MAGI system interface
 */

// MARK: - VGA Hardware Constants

/// VGA text mode hardware specifications
private let VGA_WIDTH: Int = 80
private let VGA_HEIGHT: Int = 25
private let VGA_MEMORY: UInt32 = 0xB8000

// MARK: - VGA Hardware Color System

/// VGA 4-bit color palette (hardware specification)
@frozen
enum VGAColor: UInt8 {
    case black = 0
    case blue = 1
    case green = 2
    case cyan = 3
    case red = 4
    case magenta = 5
    case brown = 6
    case lightGrey = 7
    case darkGrey = 8
    case lightBlue = 9
    case lightGreen = 10
    case lightCyan = 11
    case lightRed = 12
    case lightMagenta = 13
    case lightBrown = 14
    case white = 15
}

// MARK: - VGA Hardware Interface

/// Combine foreground and background colors (BBBBFFFF format)
@inline(__always)
private func vgaEntryColor(foreground: VGAColor, background: VGAColor) -> UInt8 {
    return foreground.rawValue | (background.rawValue << 4)
}

/// Create VGA character entry (2 bytes: character + attributes)
@inline(__always)
private func vgaEntry(character: UInt8, color: UInt8) -> UInt16 {
    return UInt16(character) | (UInt16(color) << 8)
}

// MARK: - Terminal Hardware State

/// VGA terminal state management
private final class TerminalState {
    var row: Int = 0
    var column: Int = 0
    var color: UInt8 = 0
    var buffer: UnsafeMutablePointer<UInt16>

    init() {
        self.buffer = UnsafeMutablePointer<UInt16>(bitPattern: Int(VGA_MEMORY))!
        self.color = vgaEntryColor(foreground: .lightCyan, background: .black)
    }
}

/// Global terminal hardware interface
private let terminal = TerminalState()

// MARK: - Terminal Hardware Operations

/// Initialize VGA terminal hardware
private func terminalInitialize() {
    terminal.row = 0
    terminal.column = 0
    terminal.color = vgaEntryColor(foreground: .lightCyan, background: .black)

    // Clear VGA buffer
    for y in 0..<VGA_HEIGHT {
        for x in 0..<VGA_WIDTH {
            let index = y * VGA_WIDTH + x
            terminal.buffer[index] = vgaEntry(character: UInt8(ascii: " "), color: terminal.color)
        }
    }
}

/// Write character to VGA buffer at cursor position
private func terminalPutchar(_ character: UInt8) {
    if character == UInt8(ascii: "\n") {
        terminal.column = 0
        terminal.row += 1
        if terminal.row >= VGA_HEIGHT {
            terminal.row = 0
        }
        return
    }

    let index = terminal.row * VGA_WIDTH + terminal.column
    terminal.buffer[index] = vgaEntry(character: character, color: terminal.color)

    terminal.column += 1
    if terminal.column >= VGA_WIDTH {
        terminal.column = 0
        terminal.row += 1
        if terminal.row >= VGA_HEIGHT {
            terminal.row = 0
        }
    }
}

/// Write buffer to terminal
private func terminalWrite(_ data: UnsafePointer<UInt8>, size: Int) {
    for i in 0..<size {
        terminalPutchar(data[i])
    }
}

/// Calculate C string length
private func swiftStrlen(_ str: UnsafePointer<UInt8>) -> Int {
    var length = 0
    while str[length] != 0 {
        length += 1
    }
    return length
}

/// Write null-terminated string with formatting
private func terminalWritestring(_ data: UnsafePointer<UInt8>) {
    let dataLength = swiftStrlen(data)

    // Add spacing for alignment
    for _ in 0..<5 {
        terminalPutchar(UInt8(ascii: " "))
    }

    for i in 0..<dataLength {
        terminalPutchar(data[i])
    }
}

/// Set terminal color attributes
private func terminalSetcolor(_ color: UInt8) {
    terminal.color = color
}

// MARK: - MAGI System Interface

/// MAGI system initialization sequence
private func displayMAGIStartup() {
    terminalSetcolor(vgaEntryColor(foreground: .lightRed, background: .black))
    terminalWritestring("======================================\n")
    terminalWritestring("MAGI SYSTEM STARTUP SEQUENCE INITIATED\n")
    terminalWritestring("======================================\n\n")

    terminalSetcolor(vgaEntryColor(foreground: .lightCyan, background: .black))
    terminalWritestring("CASPER... ")
    terminalSetcolor(vgaEntryColor(foreground: .lightGreen, background: .black))
    terminalWritestring("ONLINE\n")

    terminalSetcolor(vgaEntryColor(foreground: .lightCyan, background: .black))
    terminalWritestring("MELCHIOR... ")
    terminalSetcolor(vgaEntryColor(foreground: .lightGreen, background: .black))
    terminalWritestring("ONLINE\n")

    terminalSetcolor(vgaEntryColor(foreground: .lightCyan, background: .black))
    terminalWritestring("BALTHASAR... ")
    terminalSetcolor(vgaEntryColor(foreground: .lightGreen, background: .black))
    terminalWritestring("ONLINE\n\n")
}

/// Display kernel status information
private func displaySystemInfo() {
    terminalSetcolor(vgaEntryColor(foreground: .lightMagenta, background: .black))
    terminalWritestring("MAGIos v0.0.1 - Swift Edition\n")
    terminalSetcolor(vgaEntryColor(foreground: .white, background: .black))
    terminalWritestring("Boot Successful (Swift Kernel Active)\n\n")

    terminalSetcolor(vgaEntryColor(foreground: .lightBrown, background: .black))
    terminalWritestring("System Status:\n")
    terminalSetcolor(vgaEntryColor(foreground: .white, background: .black))
    terminalWritestring("- Kernel: Swift Embedded + C Assembly\n")
    terminalWritestring("- Memory: 1MB+ physical (Swift managed)\n")
    terminalWritestring("- VGA: 80x25 text mode (Swift controlled)\n")
    terminalWritestring("- Runtime: Embedded Swift (ARC disabled)\n\n")
}

/// Display final initialization status
private func displayFinalMessage() {
    terminalSetcolor(vgaEntryColor(foreground: .lightRed, background: .black))
    terminalWritestring("Hello, World from Swift MAGIos!\n")
    terminalSetcolor(vgaEntryColor(foreground: .lightGrey, background: .black))
    terminalWritestring("Swift kernel initialized successfully...\n")

    terminalSetcolor(vgaEntryColor(foreground: .lightMagenta, background: .black))
    terminalWritestring("AT Field operational. Pattern Blue.\n")
    terminalSetcolor(vgaEntryColor(foreground: .lightGrey, background: .black))
    terminalWritestring("System entering infinite idle loop...\n")
}

// MARK: - Kernel Entry Points

/// Main Swift kernel entry point (called from C bootstrap)
@_cdecl("swift_kernel_main")
public func swiftKernelMain() {
    terminalInitialize()
    displayMAGIStartup()
    displaySystemInfo()
    displayFinalMessage()
}

/// C-compatible terminal string output
@_cdecl("swift_terminal_writestring")
public func swiftTerminalWritestring(_ data: UnsafePointer<UInt8>) {
    terminalWritestring(data)
}

/// C-compatible terminal color control
@_cdecl("swift_terminal_setcolor")
public func swiftTerminalSetcolor(_ color: UInt8) {
    terminalSetcolor(color)
}

/// C-compatible terminal initialization
@_cdecl("swift_terminal_initialize")
public func swiftTerminalInitialize() {
    terminalInitialize()
}

/*
 * MAGIos Swift Kernel Implementation Summary
 *
 * Core Features:
 * - Hardware-direct VGA text mode control
 * - MAGI system initialization sequence
 * - C/Swift interoperability layer
 * - Memory-safe pointer operations
 * - Embedded Swift optimizations
 *
 * Architecture:
 * - Freestanding embedded Swift environment
 * - Direct hardware memory access (0xB8000)
 * - Minimal runtime footprint
 * - Compatible with C bootstrap code
 */
