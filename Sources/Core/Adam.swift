// Adam is the first
// Maurice Elliott 20250904 - Rewritten 20250922
// This is the Terminal Dogma of MAGIos.
// As little as possible should be defined here.

public func printLine(_ string: String){
    func putChar(_ character: UInt8,_ uart_out: UnsafeMutablePointer<UInt8>,_ uart_line_stat: UnsafePointer<UInt8>) {
        while (uart_line_stat.pointee & 0x20) == 0 { /*wait for uart to be ready for next character*/ }
        for _ in 0..<100 { /* small delay */ }
        uart_out.pointee = character
    }

    let output = "\(string)\n"
    var uart_out_register: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(bitPattern: 0x10000000)!
    var uart_line_status_register: UnsafePointer<UInt8> = UnsafePointer(bitPattern: 0x10000005)!
    var count = 0
    for byte in output.utf8 {
        if count % 15 == 0 {
            uart_out_register = UnsafeMutablePointer(bitPattern: 0x10000000)!
            uart_line_status_register = UnsafePointer(bitPattern: 0x10000005)!
        }
        putChar(byte, uart_out_register, uart_line_status_register)
        count += 1
    }
}

// public func printLine2(_ string: String){
//     let uart_out_register: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(bitPattern: 0x10000000)!
//         // Wait until UART is ready (bit 5 of LSR = Transmission holding register is empty)
//     let uart_line_status_register: UnsafePointer<UInt8> = UnsafePointer(bitPattern: 0x10000005)!

//      func putChar(_ character: UInt8) {
//         while (uart_line_status_register.pointee & 0x20) == 0 { /*wait for uart to be ready for next character*/ }
//         for _ in 0..<100 { /* small delay */ }
//         uart_out_register.pointee = character
//     }

//     let output = "\(string)"

//     for byte in output.utf8 {
//         putChar(byte)
//     }
// }


// SO essentially, the issue is the register that passes the bytes to uart is overflowing, its only 16 bytes in size
// And so we need to chunk the data and slowly send it chunk by chunk to the the uart_out_register by essentially
// calulating the size of the array and then sending it bit by bit.
// I am exhausted after this week of sickness though so will aim to pick up tomorrow. Hopefully this can help
// remind me of what I was doing.


public func bootMessage() {
    printLine("============================================================")
    printLine("================ Entering Central Dogma ====================")
    printLine("============================================================")

    printLine("\n")
    printLine("BAL Boot Successful...initiating MEL boot sequence...")
    printLine("")
    printLine("MEL Boot Successful...initiating CAS boot sequence...")
    printLine("")
    printLine("CAS Boot Successful....")
    printLine("All MAGI Have come online....")
    printLine("MAGI Sync Initiated....")
    printLine(".")
    printLine("..")
    printLine("...")
    printLine(".....")
    printLine("...........")
    printLine("............")
    printLine("............")
    printLine("..............................")
    printLine("...........................................................")
    printLine("\n")
    printLine("Syncronisation Complete, all systems Nominal")
    printLine("\n\n Good Morning Professor")
}

@_cdecl("kernel_main")
public func kernel_main() -> Never {
    // bootMessage()
    // printLine2("hello2")
    printLine("Hello World!!!")// Max limit for 1 chunk
    printLine("Hello World!!!!")//Overflow into second chunk
    while true {}
}
