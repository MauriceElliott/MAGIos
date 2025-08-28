// MAGIos Kernel - Standard Swift Implementation
// Minimal kernel for x86_64 with VGA text output

@MainActor
@main
struct Adam {
    // VGA Text Mode Constants
    static let VGA_BUFFER_ADDRESS: UInt = 0xB8000
    static let VGA_WIDTH: Int = 80
    static let VGA_HEIGHT: Int = 25
    static let VGA_DEFAULT_COLOR: UInt8 = 0x0A  // Light green on black

    // Demo mode for testing (when not on bare metal)
    static let DEMO_MODE = false

    // Global cursor position
    static var cursorX: Int = 0
    static var cursorY: Int = 0

    static func main() {
        // Debug: verify function is called
        print("DEBUG: MAGIos kernel starting...")

        // Initialize VGA and display boot message
        clearScreen()

        // Display boot messages
        WriteLine("MAGI SYSTEM INITIALIZING...")
        WriteLine("TERMINAL DOGMA ONLINE")
        WriteLine("EVANGELION UNIT-01 READY")

        if DEMO_MODE {
            // Demo mode: exit cleanly
            print("VGA Output: [SYSTEM HALTED]")
            return
        }

        // Halt system
        while true {
            // CPU halt loop
        }
    }

    // Main WriteLine function
    static func WriteLine(_ message: String) {
        if DEMO_MODE {
            // Demo mode: output to console for testing
            print("VGA Output: \(message)")
        } else {
            // Real mode: write directly to VGA buffer
            for char in message.utf8 {
                writeChar(char, color: VGA_DEFAULT_COLOR)
            }
            // Move to next line
            newLine()
        }
    }

    // Write a single character to VGA buffer
    static func writeChar(_ char: UInt8, color: UInt8) {
        let buffer = UnsafeMutablePointer<UInt16>(bitPattern: VGA_BUFFER_ADDRESS)!
        let position = cursorY * VGA_WIDTH + cursorX

        if position < VGA_WIDTH * VGA_HEIGHT {
            let vgaEntry = UInt16(color) << 8 | UInt16(char)
            buffer[position] = vgaEntry

            cursorX += 1
            if cursorX >= VGA_WIDTH {
                newLine()
            }
        }
    }

    // Move to next line
    static func newLine() {
        cursorX = 0
        cursorY += 1
        if cursorY >= VGA_HEIGHT {
            scrollScreen()
            cursorY = VGA_HEIGHT - 1
        }
    }

    // Clear the entire screen
    static func clearScreen() {
        if DEMO_MODE {
            // Demo mode: just print a clear message
            print("VGA Output: [SCREEN CLEARED]")
        } else {
            // Real mode: clear VGA buffer
            let buffer = UnsafeMutablePointer<UInt16>(bitPattern: VGA_BUFFER_ADDRESS)!
            let clearEntry = UInt16(VGA_DEFAULT_COLOR) << 8 | UInt16(32)  // Space character

            for i in 0..<(VGA_WIDTH * VGA_HEIGHT) {
                buffer[i] = clearEntry
            }

            cursorX = 0
            cursorY = 0
        }
    }
    // Scroll screen up by one line
    static func scrollScreen() {
        let buffer = UnsafeMutablePointer<UInt16>(bitPattern: VGA_BUFFER_ADDRESS)!

        // Move all lines up
        for row in 1..<VGA_HEIGHT {
            for col in 0..<VGA_WIDTH {
                let sourcePos = row * VGA_WIDTH + col
                let destPos = (row - 1) * VGA_WIDTH + col
                buffer[destPos] = buffer[sourcePos]
            }
        }

        // Clear the last line
        let clearEntry = UInt16(VGA_DEFAULT_COLOR) << 8 | UInt16(32)  // Space character
        for col in 0..<VGA_WIDTH {
            let pos = (VGA_HEIGHT - 1) * VGA_WIDTH + col
            buffer[pos] = clearEntry
        }
    }
}
