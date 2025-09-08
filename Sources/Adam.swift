// Adam is the first
// Maurice Elliott 20250904
// This is the Terminal Dogma of MAGIos - Treat it with respect.
// As little as possible should be defined here.
// This is only for the truely important.

@_cdecl("kernel_main")
public func kernel_main() -> Never {
    let vga = UnsafeMutablePointer<UInt16>(bitPattern: 0xB8000)!
    let attr = UInt16(0x0F) << 8

    let bootMessage: StaticString = "Hello World!"
    bootMessage.withUTF8Buffer { buf in
        var i = 0
        while i < buf.count {
            vga[i] = attr | UInt16(buf[i])
            i += 1
        }
    }
    
    while true {
        //halt
    }
}
