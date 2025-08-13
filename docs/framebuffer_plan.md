# MAGIos Framebuffer & Text Rendering Implementation Plan

## Objective

Implement a framebuffer and double buffering system in MAGIos to eliminate screen flicker and tearing, providing smooth text rendering output in QEMU. The initial goal is to render text only, not shapes or graphical primitives.

**Status: Significant Progress Made - Core rendering system implemented in `tabris.odin`**

---

## Step-by-Step Plan

### 1. **Design Framebuffer Structure** ✅ **COMPLETE**

- ✅ Resolution chosen: 640x480 pixels
- ✅ Color depth chosen: 32-bit RGBA (0xAARRGGBB format)
- ✅ Framebuffer structure defined in `tabris.odin`:
  - `FBUFFER`: Front buffer (what the display reads)
  - `BBUFFER`: Back buffer (where drawing operations occur)

---

### 2. **Allocate Framebuffers in Memory** ✅ **COMPLETE**

- ✅ Two buffers allocated as global arrays in kernel space
- ✅ Both buffers are 640x480x4 bytes (32-bit RGBA)
- ✅ Accessible to all drawing and display routines

---

### 3. **Implement Text Rendering Routines** ✅ **COMPLETE**

- ✅ `update_pixel()`: Sets pixel color in back buffer
- ✅ `string_to_psf_buffer()`: Retrieves font glyphs from PSF2 font data
- ✅ `draw_rune_with_magic()`: Renders individual glyph bitmaps to back buffer
- ✅ `draw_string()`: Renders complete strings with proper character positioning
- ✅ PSF2 font parsing with proper header offset handling
- ✅ 16x16 pixel glyph rendering with bit-level precision

---

### 4. **Integrate Double Buffering Logic** 🚧 **IN PROGRESS**

- 🚧 Buffer swap mechanism not yet implemented
- 🚧 Need function to copy BBUFFER to FBUFFER
- 🚧 Timer interrupt integration pending
- ✅ Back buffer drawing operations implemented

---

### 5. **Update Main Loop and Interrupt Handler** 🚧 **PENDING**

- 🚧 Integration with boot process not yet implemented
- 🚧 Timer interrupt handler for buffer swapping needed
- ✅ All drawing operations properly target back buffer only
- 🚧 Main loop integration with `draw_string()` pending

---

### 6. **Connect Framebuffer to QEMU Display** 🚧 **PENDING**

- 🚧 QEMU graphical display backend configuration needed
- 🚧 Front buffer memory mapping to display device required
- 🚧 RISC-V display device integration pending

---

### 7. **Testing and Optimization** 🚧 **PENDING**

- 🚧 End-to-end testing pending buffer swap implementation
- 🚧 Timer frequency tuning for optimal frame rate
- 🚧 Performance profiling and optimization

---

## Pseudocode Example

```odin
// Step 1: Allocate buffers
front_buffer: [WIDTH * HEIGHT]u32
back_buffer:  [WIDTH * HEIGHT]u32

// Step 2: Drawing function
draw_pixel :: proc(x: int, y: int, color: u32) {
    back_buffer[x + y * WIDTH] = color
}

// Step 3: Main loop
main_loop :: proc() {
    while running {
        // Render text to back buffer
        render_text(back_buffer, "MAGIos Booting...")

        // Wait for timer interrupt or redraw signal
        if redraw_flag {
            // Step 4: Copy back buffer to front buffer
            memcpy(front_buffer, back_buffer, sizeof(front_buffer))
            redraw_flag = false
        }
    }
}

// Step 4: Timer interrupt handler
on_timer_interrupt :: proc() {
    redraw_flag = true
    // Set next timer interrupt
    set_timer(get_time() + FRAME_INTERVAL)
}
```

---

## Next Steps

Based on current progress in `tabris.odin`:

1. ✅ ~~Finalize framebuffer resolution and color format~~ **COMPLETE**
2. ✅ ~~Implement buffer allocation and text rendering routines~~ **COMPLETE**
3. 🚧 **IMMEDIATE NEXT STEPS:**
   - Implement buffer swap function (`swap_buffers()` or similar)
   - Add timer interrupt handler to trigger buffer swaps
   - Integrate `draw_string()` with boot sequence in `adam.odin`
   - Map front buffer to QEMU display memory region
4. 🚧 **SUBSEQUENT STEPS:**
   - Connect front buffer to QEMU graphical display
   - Test end-to-end rendering pipeline
   - Optimize performance and eliminate flicker

---

## Current Implementation Status

### Completed Components (in `tabris.odin`)

- **Double buffering infrastructure**: `FBUFFER` and `BBUFFER` arrays
- **Pixel manipulation**: `update_pixel()` for back buffer drawing
- **PSF2 font support**: Proper header parsing and glyph extraction
- **Glyph rendering**: `draw_rune_with_magic()` with bit-level precision
- **String rendering**: `draw_string()` with character positioning and newline support
- **Global cursor tracking**: `posx`/`posy` for text positioning

### Missing Components

- Buffer swapping mechanism
- Timer interrupt integration
- QEMU display connection
- Main loop integration

## References

- [OSDev Wiki: Double Buffering](https://wiki.osdev.org/Double_buffering)
- [OSDev Wiki: Framebuffer](https://wiki.osdev.org/Framebuffer)
- [RISC-V Privileged Architecture Manual](https://github.com/riscv/riscv-isa-manual/releases/latest/download/riscv-privileged.pdf)
- [PSF Font Format Specification](https://www.win.tue.nl/~aeb/linux/kbd/font-formats-1.html)

---

_Prepared by: MAGIos Engineering Team_
_Last Updated: Current implementation progress in tabris.odin_
