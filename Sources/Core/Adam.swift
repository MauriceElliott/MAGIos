// Adam is the first
// Maurice Elliott 20250904 - Rewritten 20250922
// This is the Terminal Dogma of MAGIos.
// As little as possible should be defined here.

@_cdecl("kernel_main")
public func kernel_main() -> Never {
    let uart_out_register: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(bitPattern: 0x10000000)!
    let uart_line_status_register: UnsafePointer<UInt8> = UnsafePointer(bitPattern: 0x10000005)!
    
    func putchar(_ character: UInt8) {
        // Wait until UART is ready (bit 5 of LSR = Transmission holding register is empty)
        while (uart_line_status_register.pointee & 0x20) == 0 {
            // Output is not ready for next character.
        }
        uart_out_register.pointee = character
    }
    

    let msg = "Hello World from inside MAGIos!\n"

    for byte in msg.utf8 {
        putchar(byte)
    }

    while true {}
}
