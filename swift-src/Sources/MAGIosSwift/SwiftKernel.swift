/*
 * MAGIos Swift Kernel - Embedded Swift Implementation
 * This is the Swift implementation of the MAGIos kernel functionality
 * It provides the same VGA text output capabilities as the C version
 * but with Swift's safety and modern language features
 */

// MARK: - VGA Text Mode Constants

/// Standard VGA text mode dimensions and memory layout
private let VGA_WIDTH: Int = 80
private let VGA_HEIGHT: Int = 25
private let VGA_MEMORY: UInt32 = 0xB8000

// MARK: - VGA Color System

/// VGA color enumeration matching the hardware color palette
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

// MARK: - VGA Helper Functions

/// Combines foreground and background colors into a single byte
/// Format: BBBBFFFF (4 bits background, 4 bits foreground)
@inline(__always)
private func vgaEntryColor(foreground: VGAColor, background: VGAColor) -> UInt8 {
    return foreground.rawValue | (background.rawValue << 4)
}

/// Creates a VGA text mode entry (character + attributes)
/// Each character takes 2 bytes: ASCII character + color attributes
@inline(__always)
private func vgaEntry(character: UInt8, color: UInt8) -> UInt16 {
    return UInt16(character) | (UInt16(color) << 8)
}

// MARK: - Terminal State

/// Global terminal state - using class for reference semantics
private final class TerminalState {
    var row: Int = 0
    var column: Int = 0
    var color: UInt8 = 0
    var buffer: UnsafeMutablePointer<UInt16>

    init() {
        // Map VGA text buffer directly to memory
        self.buffer = UnsafeMutablePointer<UInt16>(bitPattern: Int(VGA_MEMORY))!
        self.color = vgaEntryColor(foreground: .lightCyan, background: .black)
    }
}

/// Shared terminal instance
private let terminal = TerminalState()

// MARK: - Terminal Functions

/// Initialize the terminal display system
private func terminalInitialize() {
    // Reset cursor position
    terminal.row = 0
    terminal.column = 0

    // Set default Evangelion-style colors
    terminal.color = vgaEntryColor(foreground: .lightCyan, background: .black)

    // Clear the entire screen with spaces
    for y in 0..<VGA_HEIGHT {
        for x in 0..<VGA_WIDTH {
            let index = y * VGA_WIDTH + x
            terminal.buffer[index] = vgaEntry(character: UInt8(ascii: " "), color: terminal.color)
        }
    }
}

/// Display a single character at the current cursor position
private func terminalPutchar(_ character: UInt8) {
    // Handle newline character
    if character == UInt8(ascii: "\n") {
        terminal.column = 0
        terminal.row += 1
        if terminal.row >= VGA_HEIGHT {
            terminal.row = 0  // Wrap to top (could implement scrolling later)
        }
        return
    }

    // Calculate position in linear buffer
    let index = terminal.row * VGA_WIDTH + terminal.column

    // Write character and color to VGA buffer
    terminal.buffer[index] = vgaEntry(character: character, color: terminal.color)

    // Advance cursor position
    terminal.column += 1
    if terminal.column >= VGA_WIDTH {
        terminal.column = 0
        terminal.row += 1
        if terminal.row >= VGA_HEIGHT {
            terminal.row = 0  // Wrap to top
        }
    }
}

/// Output a buffer of known size
private func terminalWrite(_ data: UnsafePointer<UInt8>, size: Int) {
    for i in 0..<size {
        terminalPutchar(data[i])
    }
}

/// Calculate string length (embedded Swift doesn't have full stdlib)
private func swiftStrlen(_ str: UnsafePointer<UInt8>) -> Int {
    var length = 0
    while str[length] != 0 {
        length += 1
    }
    return length
}

/// Display a null-terminated string with spacing
private func terminalWritestring(_ data: UnsafePointer<UInt8>) {
    let dataLength = swiftStrlen(data)
    let spaces = "     "

    // Write leading spaces
    for char in spaces.utf8 {
        terminalPutchar(char)
    }

    // Write the actual string
    for i in 0..<dataLength {
        terminalPutchar(data[i])
    }
}

/// Change terminal text color
private func terminalSetcolor(_ color: UInt8) {
    terminal.color = color
}

// MARK: - MAGI System Display Functions

/// Display the MAGI system startup sequence
private func displayMAGIStartup() {
    // Header message in red
    terminalSetcolor(vgaEntryColor(foreground: .lightRed, background: .black))
    terminalWritestring("======================================\n")
    terminalWritestring("MAGI SYSTEM STARTUP SEQUENCE INITIATED\n")
    terminalWritestring("======================================\n\n")

    // CASPER subsystem
    terminalSetcolor(vgaEntryColor(foreground: .lightCyan, background: .black))
    terminalWritestring("CASPER... ")
    terminalSetcolor(vgaEntryColor(foreground: .lightGreen, background: .black))
    terminalWritestring("ONLINE\n")

    // MELCHIOR subsystem
    terminalSetcolor(vgaEntryColor(foreground: .lightCyan, background: .black))
    terminalWritestring("MELCHIOR... ")
    terminalSetcolor(vgaEntryColor(foreground: .lightGreen, background: .black))
    terminalWritestring("ONLINE\n")

    // BALTHASAR subsystem
    terminalSetcolor(vgaEntryColor(foreground: .lightCyan, background: .black))
    terminalWritestring("BALTHASAR... ")
    terminalSetcolor(vgaEntryColor(foreground: .lightGreen, background: .black))
    terminalWritestring("ONLINE\n\n")
}

/// Display system information and status
private func displaySystemInfo() {
    // Main welcome message
    terminalSetcolor(vgaEntryColor(foreground: .lightMagenta, background: .black))
    terminalWritestring("MAGIos v0.0.1 - Swift Edition\n")
    terminalSetcolor(vgaEntryColor(foreground: .white, background: .black))
    terminalWritestring("Boot Successful (Swift Kernel Active)\n\n")

    // System status
    terminalSetcolor(vgaEntryColor(foreground: .lightBrown, background: .black))
    terminalWritestring("System Status:\n")
    terminalSetcolor(vgaEntryColor(foreground: .white, background: .black))
    terminalWritestring("- Kernel: Swift Embedded + C Assembly\n")
    terminalWritestring("- Memory: 1MB+ physical (Swift managed)\n")
    terminalWritestring("- VGA: 80x25 text mode (Swift controlled)\n")
    terminalWritestring("- Runtime: Embedded Swift (ARC disabled)\n\n")
}

/// Display final startup messages
private func displayFinalMessage() {
    terminalSetcolor(vgaEntryColor(foreground: .lightRed, background: .black))
    terminalWritestring("Hello, World from Swift MAGIos!\n")
    terminalSetcolor(vgaEntryColor(foreground: .lightGrey, background: .black))
    terminalWritestring("Swift kernel initialized successfully...\n")

    // AT Field reference
    terminalSetcolor(vgaEntryColor(foreground: .lightMagenta, background: .black))
    terminalWritestring("AT Field operational. Pattern Blue.\n")
    terminalSetcolor(vgaEntryColor(foreground: .lightGrey, background: .black))
    terminalWritestring("System entering infinite idle loop...\n")
}

// MARK: - Public C Interface

/// Main Swift kernel entry point - called from C
/// This replaces the kernel_main function from the C version
@_cdecl("swift_kernel_main")
public func swiftKernelMain() {
    // Initialize the terminal display system
    terminalInitialize()

    // Display the full MAGI startup sequence
    displayMAGIStartup()
    displaySystemInfo()
    displayFinalMessage()

    // The Swift kernel portion is complete
    // Control will return to C for the infinite halt loop
}

/// Swift version of terminal_writestring for C interop
@_cdecl("swift_terminal_writestring")
public func swiftTerminalWritestring(_ data: UnsafePointer<UInt8>) {
    terminalWritestring(data)
}

/// Swift version of terminal_setcolor for C interop
@_cdecl("swift_terminal_setcolor")
public func swiftTerminalSetcolor(_ color: UInt8) {
    terminalSetcolor(color)
}

/// Swift version of terminal_initialize for C interop
@_cdecl("swift_terminal_initialize")
public func swiftTerminalInitialize() {
    terminalInitialize()
}

// MARK: - Swift-specific Extensions

/// Extended color functionality for future Swift-only features
extension VGAColor {
    /// Get the Eva Unit color scheme
    static var evaUnit01: VGAColor { .lightMagenta }
    static var evaUnit00: VGAColor { .lightBlue }
    static var evaUnit02: VGAColor { .lightRed }
    static var angelPattern: VGAColor { .lightCyan }
    static var atField: VGAColor { .lightBrown }
}

/// Future expansion: Swift-only terminal effects
private struct TerminalEffects {
    static func displayATFieldPattern() {
        // Could implement animated AT Field hexagon pattern
        // This would be a Swift-exclusive feature
    }

    static func displayAngelDetection() {
        // Could implement Angel detection warning system
        // Another Swift-exclusive feature
    }
}

/*
 * SUMMARY OF SWIFT KERNEL FEATURES:
 *
 * PORTED FROM C:
 * 1. Complete VGA text mode system
 * 2. All terminal output functions
 * 3. MAGI startup sequence with Evangelion theming
 * 4. C interoperability via @_cdecl functions
 *
 * SWIFT ENHANCEMENTS:
 * 1. Type safety with enums and structs
 * 2. Memory safety with proper pointer handling
 * 3. Clean API design with private/public separation
 * 4. Extensible architecture for future features
 * 5. Embedded Swift optimizations
 *
 * TECHNICAL DETAILS:
 * 1. Direct VGA memory access via UnsafeMutablePointer
 * 2. No Swift runtime dependencies (embedded mode)
 * 3. Compatible with existing C/Assembly boot code
 * 4. Maintains same memory layout and calling conventions
 */
