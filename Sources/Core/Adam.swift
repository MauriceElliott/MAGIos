// Adam is the first
// Maurice Elliott 20250904 - Rewritten 20250922
// This is the Terminal Dogma of MAGIos.
// As little as possible should be defined here.

public func printChunkToUart(_ bytes: UnsafeBufferPointer<UInt8>){
    let uart_out_register: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(bitPattern: 0x10000000)!
    let uart_line_status_register: UnsafePointer<UInt8> = UnsafePointer(bitPattern: 0x10000005)!

    func putChar(_ character: UInt8) {
        while (uart_line_status_register.pointee & 0x20) == 0 { /*wait for uart to be ready for next character*/ }
        for _ in 0..<100 { /* small delay */ }
        uart_out_register.pointee = character
    }
    for byte in bytes {
        putChar(byte)
    }
}

public func print(_ string: StaticString) {
    let totalBytes = string.utf8CodeUnitCount
    let bytesPtr = string.utf8Start
    let chunkSize = 14

    var offset = 0
    while offset < totalBytes {
        let remainingBytes = totalBytes - offset
        let currentChunkSize = remainingBytes < chunkSize ? remainingBytes : chunkSize

        let chunkBuffer = UnsafeBufferPointer(
            start: bytesPtr.advanced(by: offset),
            count: currentChunkSize
        )

        printChunkToUart(chunkBuffer)
        offset += currentChunkSize
    }
}

public func bootMessage() {
    print("============================================================\n")
    print("================ Entering Central Dogma ====================\n")
    print("============================================================\n")

    print("\n")
    print("BAL Boot Successful...initiating MEL boot sequence...\n")
    print("\n")
    print("MEL Boot Successful...initiating CAS boot sequence...\n")
    print("\n")
    print("CAS Boot Successful....\n")
    print("All MAGI Have come online....\n")
    print("MAGI Sync Initiated....\n")
    print("\n")
    print("Syncronisation Complete, all systems Nominal\n")
    print("\n\n Good Morning Professor\n")
}

@_cdecl("kernel_main")
public func kernel_main() -> Never {
    bootMessage()
    while true {}
}


/*
30-09-25 - Converted from using String type to StaticString as the strings I was using were causing uneccessary complexity.
*/
