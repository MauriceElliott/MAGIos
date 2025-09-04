// Maurice Elliott 20250905
// This is the Kernel of MAGIos, It must also be respected

import Core

@_cdecl("kernel")
public func kernel() -> Never {
    Wake()
    while true {
        //halt
    }
}
