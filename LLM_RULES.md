# LLM Rules for MAGIos Project

## Project Overview

**MAGIos** is a 32-bit operating system written primarily in **Swift**, designed as an art piece inspired by the aesthetic of the 1990s anime series _Neon Genesis Evangelion_. This is **not** business or casual-use software - it is an experimental, artistic operating system kernel that prioritizes aesthetic and technical exploration over practical utility.

## Core Principles

### Language Priority

1. **Swift First**: This project is Swift-first and foremost
2. **C Where Necessary**: Use C only where Swift cannot be used (bootstrap, hardware initialization)
3. **No Other Languages**: Avoid introducing additional languages unless absolutely critical

### Aesthetic & Theme

- Maintain the Evangelion aesthetic throughout all code and documentation
- Use MAGI system references (CASPER, MELCHIOR, BALTHASAR)
- Preserve the 90s anime tech atmosphere in all user-facing elements
- Terminal output should feel like interacting with the MAGI supercomputers

## LLM Interaction Guidelines

### Error Handling & Attempts

- **Maximum 2 attempts** to fix any single issue before rechecking these rules
- **Maximum 6 total attempts** without checking back with the user for direction
- When stuck, always reference back to these rules and ask for human guidance

### Code Changes

- Prioritize Swift solutions over C solutions
- Maintain existing Evangelion theming in all modifications
- Preserve the artistic nature of the project - don't over-optimize for practical use
- Keep the 32-bit architecture constraint
- Maintain compatibility with Embedded Swift requirements

### Build System Philosophy

- Centralize configuration where possible
- Minimize duplication between Makefile and build scripts
- Prioritize clarity and maintainability over complex optimizations
- Keep the aesthetic elements (status messages, progress indicators) while improving efficiency

### Documentation Style

- Maintain Evangelion references in technical documentation
- Use MAGI system terminology consistently
- Keep the dramatic, anime-inspired tone in user-facing messages
- Technical accuracy with thematic presentation
- After updating logic, make sure the comments at the bottom of the file are updated to reflect the changes made.
- If anything that is relevant for the rules file is discussed during usage make sure the rules file is updated.

## Technical Constraints

### Platform Requirements

- **Target**: 32-bit x86 architecture
- **Development Platform**: macOS preferred
- **Swift Version**: Embedded Swift (development snapshots only)
- **Boot Method**: Multiboot-compliant via GRUB

### Dependencies

- Swift development toolchain (not release versions)
- Cross-compiler toolchain (i686-elf-gcc)
- QEMU for testing
- NASM for assembly
- Standard build tools (make, etc.)

## Forbidden Actions

1. **Do not** remove or significantly alter the Evangelion theming
2. **Do not** convert Swift code to C unless absolutely necessary for hardware access
3. **Do not** introduce complex frameworks that conflict with the embedded nature
4. **Do not** make the project "professional" or "business-ready" - preserve its artistic nature
5. **Do not** continue indefinitely without human input when encountering repeated failures

## Success Criteria

- Swift kernel successfully compiles and boots
- MAGI system aesthetic is preserved and enhanced
- Build process is simplified while maintaining functionality
- All toolchain dependencies are properly managed
- QEMU execution works via `./build.sh --run`

## When in Doubt

1. Check these rules first
2. Prioritize Swift over C
3. Maintain the Evangelion aesthetic
4. Ask the human for guidance rather than making assumptions
5. Remember: this is art, not enterprise software

---

_AT Field operational. Pattern Blue. Synchronization rate holding steady._
