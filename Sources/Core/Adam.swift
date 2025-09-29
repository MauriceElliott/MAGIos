// Adam is the first
// Maurice Elliott 20250904 - Rewritten 20250922
// This is the Terminal Dogma of MAGIos.
// As little as possible should be defined here.

public func printChunkToUart(_ string: String){
    let uart_out_register: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer(bitPattern: 0x10000000)!
    let uart_line_status_register: UnsafePointer<UInt8> = UnsafePointer(bitPattern: 0x10000005)!

    func putChar(_ character: UInt8) {
        while (uart_line_status_register.pointee & 0x20) == 0 { /*wait for uart to be ready for next character*/ }
        for _ in 0..<100 { /* small delay */ }
        uart_out_register.pointee = character
    }
    for byte in string.utf8 {
        putChar(byte)
    }
}

public func printLine(_ string: String) {
    let bytes = Array(string.utf8)
    let chunkSize = 14
    printChunkToUart(string)
    for i in stride(from: 0, to: bytes.count, by: chunkSize) {
        let endIndex = min(i + chunkSize, bytes.count)
        let chunk = bytes[i..<endIndex]
        let chunkString = String(validating: chunk, as: UTF8.self) ?? ""
        printChunkToUart(chunkString)
    }
}

// PART 1
// SO essentially, the issue is the register that passes the bytes to uart is overflowing, its only 16 bytes in size
// And so we need to chunk the data and slowly send it chunk by chunk to the the uart_out_register by essentially
// calulating the size of the array and then sending it bit by bit.
// I am exhausted after this week of sickness though so will aim to pick up tomorrow. Hopefully this can help
// remind me of what I was doing.
// PART 2
// So now we've run into an issue where seemingly we are calling on things from the standard libary, which is causing issues.
// We need to either build the OS binary so that the Standard Libary is built in. i.e. Freestanding.
// Or we need to look at implementing the things ourselves. Or just find a more straight forward way to implement them.
// NOTES FOR NEXT TIME
// Array seems to be causing issues too, For some reason when its called the output to uart is lost, where as when its removed
// It works fine. I think we're going in the right direction with the rest, but at the same time I'm wondering if maybe
// I should just properly dumb it down, convert every string to UInt8 characters, maybe use a different string type
// like static.
// This is new territory for me so making it through is important, but so is learning here and I am having fun trying
// to work this out. I guess I just need to avoid putting pressure on completing this or getting a result.
// Its a personal project, a hobby, its only for me to see progress.


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
    printLine("\n")
    printLine("Syncronisation Complete, all systems Nominal")
    printLine("\n\n Good Morning Professor")
}

@_cdecl("kernel_main")
public func kernel_main() -> Never {
    // bootMessage()
    // printLine2("hello2")
    // printChunkToUart("Hello")
    printLine("Hello World!!!")// Max limit for 1 chunk
    // printLine("Hello World!!!!")//Overflow into second chunk
    while true {}
}
