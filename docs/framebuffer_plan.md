# MAGIos Framebuffer & Text Rendering Implementation Plan

## Objective

Implement a framebuffer and double buffering system in MAGIos to eliminate screen flicker and tearing, providing smooth text rendering output in QEMU. The initial goal is to render text only, not shapes or graphical primitives.

---

## Step-by-Step Plan

### 1. **Design Framebuffer Structure**

- Decide on resolution (e.g., 640x480, 800x600, etc.).
- Choose color depth (e.g., 32-bit RGBA, 24-bit RGB, 8-bit grayscale).
- Define a framebuffer as a contiguous block of memory:
  - `front_buffer`: What the display reads.
  - `back_buffer`: Where drawing operations occur.

---

### 2. **Allocate Framebuffers in Memory**

- Reserve two buffers in kernel memory space.
- Ensure alignment and accessibility for both drawing and display routines.

---

### 3. **Implement Text Rendering Routines**

- Functions to set pixel color in the back buffer.
- Functions to retrieve font glyphs from a string (progress: implemented and tested).
- Functions to render text glyphs to the back buffer.
- Do not implement shape or graphical primitive drawing at this stage.

---

### 4. **Integrate Double Buffering Logic**

- On each frame/timer interrupt:
  - Copy the entire back buffer to the front buffer in one operation.
  - Only the front buffer is ever read by the display hardware or QEMU.

---

### 5. **Update Main Loop and Interrupt Handler**

- Main loop renders text to the back buffer.
- Timer interrupt (or vertical blank event) triggers buffer swap/copy.
- Avoid drawing directly to the front buffer.

---

### 6. **Connect Framebuffer to QEMU Display**

- Ensure QEMU is configured to use a graphical display backend.
- Map the front buffer to the expected memory region for QEMU’s virtual graphics device (e.g., VGA, VESA, or custom MMIO).

---

### 7. **Testing and Optimization**

- Verify smooth output and absence of flicker.
- Tune timer frequency for optimal frame rate (e.g., 60Hz).
- Profile memory usage and performance.

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

1. Finalize framebuffer resolution and color format.
2. Implement buffer allocation and text rendering routines.
   - **Progress:** Font glyphs can now be retrieved from a string as byte arrays.
   - **Next:** Implement glyph drawing into the back buffer using the `draw_pixel` method.
     - For each character in the string:
       - Retrieve the glyph byte array.
       - For each row and column in the glyph:
         - If the bit is set, call `draw_pixel(x + col, y + row, fg_color)` to set the pixel in the back buffer.
         - Optionally, set background pixels if desired.
       - Advance the x position for the next character.
3. Integrate double buffering logic into main loop and interrupt handler.
4. Connect front buffer to QEMU display.
5. Test and iterate for smooth, flicker-free text output.

---

## References

- [OSDev Wiki: Double Buffering](https://wiki.osdev.org/Double_buffering)
- [OSDev Wiki: Framebuffer](https://wiki.osdev.org/Framebuffer)
- [RISC-V Privileged Architecture Manual](https://github.com/riscv/riscv-isa-manual/releases/latest/download/riscv-privileged.pdf)

---

_Prepared by: MAGIos Engineering Team_
