# MAGIos

![Logo](resources/MAGIos.png)

An operating system built for fun, based on 90s anime aesthetic, specifically neon genesis evangelion, hence the name.

![Screenshot](resources/firstLook.png)

## Embedded Swift Integration Plan

### Phase 1: Research and Toolchain Setup

1.  **Embedded Swift Toolchain:**
    *   **Research:** The most critical step is to find and set up a Swift compiler that can target your `i686-elf` platform. You'll need to investigate the state of the official Swift compiler's support for freestanding, bare-metal targets. Search for terms like "embedded swift," "swift bare metal," "swift freertos," and "swift osdev."
    *   **Action:** Download and install the appropriate Swift compiler. You may need to build it from source with specific flags. The goal is to have a `swiftc` that can produce object files compatible with your existing `i686-elf-ld` linker.

2.  **Calling Conventions and C-to-Swift Interface:**
    *   **Research:** Understand the calling conventions for both `i686-elf-gcc` and your chosen Swift compiler. This is crucial for making C and Swift code call each other. You need to know how function arguments are passed (registers vs. stack) and how return values are handled.
    *   **C-to-Swift:** To call Swift from C, you must make the Swift function visible to the C linker. This is achieved by using the `@_cdecl` attribute in your Swift code. For example, a Swift function declared as `@_cdecl("my_swift_function") func mySwiftFunction()` will be available in C as `void my_swift_function(void);`. You will then need to declare the function signature in a C header file to be included in your C source.
    *   **Action:** Document the calling conventions for both. This will be your guide for writing the C-to-Swift and Swift-to-C interface code.

3.  **Name Mangling:**
    *   **Research:** Compilers change the names of functions in the final object file (a process called name mangling). You need to understand how your C compiler and Swift compiler mangle names.
    *   **Action:** Use tools like `nm` on compiled object files to inspect the symbol names. You'll likely need to use `extern "C"` in your Swift code to prevent name mangling and make functions callable from C.

### Phase 2: "Hello, Swift!" - A Minimal Integration

1.  **Create a Swift "Kernel":**
    *   **Action:** Write a simple Swift file (e.g., `kernel.swift`) that contains a single function, let's say `swift_main()`. This function should be marked with `@_cdecl("swift_main")` to expose it to C. Inside this function, you won't be able to do much yet, as you won't have access to your C kernel's VGA functions. For now, it can just be an empty function.

2.  **Update the Makefile:**
    *   **Action:** Modify your `Makefile` to compile the Swift code. You'll need to add a new rule for `.swift` files that uses your embedded `swiftc` to create an object file (e.g., `build/kernel_swift.o`). Add this new object file to your `OBJECTS` list.

3.  **Modify the C Kernel:**
    *   **Action:** In `kernel.c`, declare the `swift_main` function as `extern void swift_main(void);`. Then, call `swift_main()` from your `kernel_main` function.

4.  **Link and Run:**
    *   **Action:** Build and run your OS. If everything is set up correctly, it should compile, link, and run without errors. You won't see any new output, but the fact that it runs proves that you've successfully integrated Swift into your build process.

### Phase 3: Interoperability - Calling C from Swift

1.  **Create a Bridging Header:**
    *   **Research:** Swift uses bridging headers to import C code. You'll need to figure out how to use one in your embedded environment.
    *   **Action:** Create a header file (e.g., `kernel.h`) that declares the C functions you want to call from Swift (like `terminal_writestring` and `terminal_setcolor`).

2.  **Expose C Functions to Swift:**
    *   **Action:** In your Swift code, import the bridging header. You should now be able to call the C functions you declared.

3.  **Write to the Screen from Swift:**
    *   **Action:** In your `swift_main` function, call `terminal_writestring` to print a message to the screen. This will be the first time you see output generated from Swift code.

### Phase 4: Advanced Topics

1.  **Swift Standard Library:**
    *   **Research:** The full Swift standard library is likely too large and has too many dependencies (like a file system and networking) to run in your OS. You'll need to investigate how to compile and link a minimal version of the standard library or a "core" subset.
    *   **Action:** Experiment with different compiler flags to control the standard library's inclusion.

2.  **Memory Management:**
    *   **Research:** Swift uses Automatic Reference Counting (ARC) for memory management. You'll need to understand how ARC works and what runtime support it requires. You may need to implement parts of the Swift runtime yourself.
    *   **Action:** Write the necessary runtime support functions for ARC.

3.  **Interrupts and Hardware Interaction:**
    *   **Research:** To write drivers and handle interrupts in Swift, you'll need to understand how to work with pointers, memory-mapped I/O, and inline assembly in Swift.
    *   **Action:** Create Swift wrappers for your hardware interaction functions.
