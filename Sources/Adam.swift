// Adam is the first
// Maurice Elliott 20250904
// This is the Terminal Dogma of MAGIos - Treat it with respect.
// As little as possible should be defined here.
// This is only for the truely important.

public struct VGA {
    let buffer: UnsafeMutablePointer<UInt16>
    var attribute: UInt16 = 0x0F << 8
}

private func InitialiseVga() -> VGA {
    return VGA(buffer: UnsafeMutablePointer<UInt16>(bitPattern: 0xB8000)!)
}

public func KernelPanic() {
    print("Crashing!!!")
}

public func WriteToVga(_ input: StaticString,_ vga: VGA) {
    input.withUTF8Buffer({ buf in
        var i = 0
        while i < buf.count {
            vga.buffer[i] = vga.attribute | UInt16(buf[i])
            i += 1
        }
    })
}

private func BootMessage(vga: VGA) -> Bool {
    WriteToVga("=================================", vga)
    WriteToVga("=== LAUNCH SEQUENCE INITIATED ===", vga)
    WriteToVga("=================================", vga)
    return false;
}

@_cdecl("kernel_main")
public func kernel_main() -> Never {
    let vga = InitialiseVga()
  
    if BootMessage(vga: vga) {
        while true {
            //halt
        }
    } else {
        KernelPanic()
    }
    while true {
        //halt
    }
}
