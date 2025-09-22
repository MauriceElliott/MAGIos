// Adam is the first
// Maurice Elliott 20250904 - Rewritten 20250922
// This is the Terminal Dogma of MAGIos.
// As little as possible should be defined here.

@_cdecl("kernel_main")
public func kernel_main() -> Never {
    let uart0: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(bitPattern: 0x10000000)!

    let msg = "Hello World!"

    for byte in msg.utf8 {
        uart0.pointee = byte
    }

    while true {}
}
