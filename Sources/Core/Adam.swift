// Adam is the first
// Maurice Elliott 20250904 - Rewritten 20250922
// This is the Terminal Dogma of MAGIos.
// As little as possible should be defined here.

public func bootMessage() {
    uartPrint("\n\n\n")
    uartPrint("============================================================\n")
    uartPrint("================ Entering Central Dogma ====================\n")
    uartPrint("============================================================\n")

    uartPrint("\n")
    uartPrint("BAL Boot Successful...initiating MEL boot sequence...\n")
    uartPrint("\n")
    uartPrint("MEL Boot Successful...initiating CAS boot sequence...\n")
    uartPrint("\n")
    uartPrint("CAS Boot Successful....\n")
    uartPrint("All MAGI Have come online....\n")
    uartPrint("MAGI Sync Initiated....\n")
    uartPrint("\n")
}

@_cdecl("kernel_main")
public func KernelMain() -> Never {
    
    bootMessage()
    setTraps()

    uartPrint("\nTrap Handler System Engaged...\n")

    uartPrint("\nSyncronisation Complete, all systems Nominal\n")

    while true {
    }
}
