//Lilith was the second, and the mother of all lilin, humanity.
// MauriceElliott - 20250908
// This is the standard libary for MAGIos, currently I've only added LLM generated stubs for functions required by the C side of things, but soon it will be feature rich.

// Memory functions
@_cdecl("memset")
public func memset(_ ptr: UnsafeMutableRawPointer, _ value: Int32, _ size: Int) -> UnsafeMutableRawPointer {
    // Fill memory with a byte value
    // ptr: pointer to memory to fill
    // value: byte value to fill with (only low 8 bits used)
    // size: number of bytes to fill
    // returns: ptr
    return ptr
}

@_cdecl("memmove")
public func memmove(_ dest: UnsafeMutableRawPointer, _ src: UnsafeRawPointer, _ size: Int) -> UnsafeMutableRawPointer {
    // Copy memory, handling overlapping regions correctly
    // dest: destination pointer
    // src: source pointer  
    // size: number of bytes to copy
    // returns: dest
    return dest
}

// Memory allocation functions
@_cdecl("posix_memalign")
public func posix_memalign(_ memptr: UnsafeMutablePointer<UnsafeMutableRawPointer?>, _ alignment: Int, _ size: Int) -> Int32 {
    // Allocate aligned memory
    // memptr: pointer to store the allocated memory address
    // alignment: memory alignment (must be power of 2)
    // size: number of bytes to allocate
    // returns: 0 on success, error code on failure
    return -1 // ENOMEM - not implemented
}

@_cdecl("free")
public func free(_ ptr: UnsafeMutableRawPointer?) {
    // Free previously allocated memory
    // ptr: pointer to memory to free (can be null)
    // returns: nothing
}


//Uart serial port output
private func printChunkToUart(_ bytes: UnsafeBufferPointer<UInt8>){
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

public func uartPrint(_ string: StaticString) {
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
