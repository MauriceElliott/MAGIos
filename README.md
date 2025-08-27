# MAGIos

A 64-bit ARM based operating system kernel written in Swift, inspired by the aesthetics and themes of Neon Genesis Evangelion.

![MAGIos](resources/MAGIos.png)

## Overview

MAGIos is experimental. It is a conduit for me to learn how an OS works as well as giving me an outlet for creativity.

Currently I am making this as a terminal type application, possibly something that could run under WSL on Windows. Eventually I would like to make a GUI library, something that fits the 90s anime theme. But the thing is this isn't just about the aesthetics of the externally facing application, this is also about the codebase, so as you can probably see, the kernel file being called adam, and the interrupt system being called lilith make this less than ideal as a learning device for others. Because of this, I have done my best to leave as many comments with as much details as is possible.

## Features

- **Pure Odin Implementation**: Kernel logic written entirely in Odin with minimal assembly bootstrap
- **ARM 64-bit Architecture**: Modern, clean instruction set
- **Evangelion Theming**: Designed to mimic the MAGI system as that aspect of Evangelion has always fascinated me
- **Cross-Platform Build**: Supports macOS and Linux development environments

## Build and Run

```bash
# Run in QEMU with serial console
./build.sh --run

# Run in headless mode (for testing)
./build.sh --test

# Clean build artifacts
./build.sh --clean
```
