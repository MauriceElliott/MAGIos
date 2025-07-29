# LLM Rules for MAGIos Project

## Project Overview

**MAGIos** is a 32-bit operating system written in **Odin**, designed as an art piece inspired by the aesthetic of the 1990s anime series _Neon Genesis Evangelion_. This is **not** business or casual-use software - it is an experimental, artistic operating system kernel that prioritizes aesthetic and technical exploration over practical utility.

## Core Principles

### Language Priority

1. **Odin First**: This project uses Odin as its primary systems programming language
2. **Assembly Where Necessary**: Use assembly for boot sequence and low-level initialization
3. **No Other Languages**: The kernel is implemented purely in Odin with minimal assembly bootstrap

### Aesthetic & Theme

- Maintain the Evangelion aesthetic throughout all code and documentation
- Use MAGI system references (CASPER, MELCHIOR, BALTHASAR)
- Preserve the 90s anime tech atmosphere in all user-facing elements
- Terminal output should feel like interacting with the MAGI supercomputers

### Build System Quality

- Tool checks must verify actual required tools (e.g. qemu-system-i386, not generic qemu)
- Build script should handle both --test (headless) and --run (GUI) modes for QEMU
- Build output should be clean and professional while maintaining the Evangelion theming

## LLM Interaction Guidelines

### Error Handling & Attempts

- **Maximum 2 attempts** to fix any single issue before rechecking these rules
- **Maximum 6 total attempts** without checking back with the user for direction
- When stuck, always reference back to these rules and ask for human guidance
- While making changes and rebuilding, always use ./build.sh --test over --run as that way it removes the need for human intervention and ensures the llm can read the output.

### Code Changes

- Prioritize idiomatic Odin solutions
- Maintain existing Evangelion theming in all modifications
- Preserve the artistic nature of the project - don't over-optimize for practical use
- Keep the 32-bit architecture constraint
- Keep comments accurate and up-to-date with implementation

### Build System Philosophy

- Keep build script simple and focused
- Prioritize clarity and maintainability
- Keep the aesthetic elements (status messages, progress indicators)

### Documentation Style

- Maintain Evangelion references in technical documentation
- Use MAGI system terminology consistently
- Keep the dramatic, anime-inspired tone in user-facing messages
- Technical accuracy with thematic presentation
- After updating logic, make sure the comments are updated to reflect the changes made
- If anything that is relevant for the rules file is discussed during usage make sure the rules file is updated

## Technical Constraints

### Platform Requirements

- **Target**: 32-bit x86 architecture
- **Development Platform**: macOS preferred
- **Odin Version**: Latest stable Odin compiler
- **Boot Method**: Multiboot-compliant via GRUB

### Dependencies

- Odin compiler
- Cross-compiler toolchain (i686-elf-gcc for assembly)
- QEMU for testing (specifically qemu-system-i386)
- NASM for assembly
- Standard build tools (bash, etc.)

## Forbidden Actions

1. **Do not** remove or significantly alter the Evangelion theming
2. **Do not** introduce languages other than Odin and minimal assembly
3. **Do not** make the project "professional" or "business-ready" - preserve its artistic nature
4. **Do not** continue indefinitely without human input when encountering repeated failures

## Success Criteria

- Odin kernel successfully compiles and boots
- MAGI system aesthetic is preserved and enhanced
- Build process is simple and functional
- All toolchain dependencies are properly managed
- QEMU execution works via `./build.sh --run` and `./build.sh --test`

## When in Doubt

1. Check these rules first
2. Write idiomatic Odin code
3. Maintain the Evangelion aesthetic
4. Ask the human for guidance rather than making assumptions
5. Remember: this is art, not enterprise software

## Recent Changes

### Odin Language Migration (2025-01-XX)

1. **Language Switch**: Migrated from Swift to Odin for better low-level control
2. **Simplified Structure**: Single kernel.odin file contains all kernel logic
3. **Build System**: Simplified build.sh script with --test and --run modes
4. **Boot Sequence**: Maintained Evangelion-themed MAGI boot messages
5. **Architecture**: Pure Odin implementation with minimal assembly bootstrap

The Odin implementation maintains the same Evangelion aesthetic while leveraging Odin's systems programming capabilities for a cleaner, more direct kernel implementation.

---

_AT Field operational. Pattern Blue. Synchronization rate holding steady._
