# MAGIos

![MAGIos](resources/MAGIos.png)

## Overview

MAGIos is experimental. It is a conduit for me to learn how an OS works as well as giving me an outlet for creativity.

## Core design principal

No pomp, only simplicity, no over engineering, only verbosity, no elegance, only robustness.
The point of this project is to learn and understand OS development, some of it will end up being complex of course, but we can strive to make it as easily understandable as possible in any way we can, that is the goal. Beautifully straight forward overly verbose, robust and commented code that I can read back in a couple years time and still understand.

## Core design

- Embedded Swift + Assembly only, no C.
- 64 bit RISCV
- Package.swift First, build.sh second
- Buildable on macOS or Gentoo Linux (My main machines)
- Qemu emulated for the duration of development

## The MAGI

In evangelion the three MAGI are three super computers that work in tandem to provide operational function to NERV and provide other things like unbiased decision making for the greater good of humanity. Each of the MAGI are based on different aspects of its creator, Dr. Naoko Akagi. Casper is her as a woman, Balthasar is her as a mother, and Melchior is her as a scientist.
I have not yet fully decided how to implement this but while writing a card for my wife's birthday I realised I had split it into three sections, describing her as firstly a Woman of Faith, then a Woman of Learning, and then her as a mother and a carer.
It would bring me great pleasure to keep these in mind when building MAGIos. We will have to wait and see how that is actually implemented, but either way I look forward to having her be a part of it.

## Main objectives in order

1. Kernal Boot Message -- Complete
2. Interupt System -- In Progress
3. Memory Management
4. Process Management
5. File System
   -- Future after research, use UART graphics for everything up til here.
6. Graphics
7. User Interface
8. Networking

## Build and Run

```bash
# Run in QEMU with serial console
./build.sh --run

# Clean build artifacts
./build.sh --clean
```
