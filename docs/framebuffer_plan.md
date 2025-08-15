# MAGIos Framebuffer & Display Implementation Plan

## Objective

Implement a framebuffer system in MAGIos to display graphics in QEMU's GUI window. The current implementation has most components working but lacks proper display output mapping.

**Status: Core rendering system complete - Display mapping needs implementation**

---

## Current Implementation Analysis

### ✅ **Completed Components**

#### Framebuffer Infrastructure (`tabris.odin`)

- ✅ Double buffering with `FBUFFER` (front) and `BBUFFER` (back) arrays
- ✅ 640x480 resolution at 32-bit RGBA color depth
- ✅ `swap_buffers()`: Copies back buffer to front buffer
- ✅ `clear_back_buffer()`: Initializes back buffer with black background

#### Text Rendering System

- ✅ `draw_character()`: Renders individual 16x16 pixel glyphs from bitmap font
- ✅ `draw_string()`: Renders complete strings with automatic line wrapping
- ✅ `update_pixel()`: Sets individual pixel colors in back buffer
- ✅ Font system using Inconsolata 16x16 bitmap font data
- ✅ Proper cursor positioning with `posx`/`posy` tracking

#### Integration Points

- ✅ Boot sequence calls framebuffer functions (`boot_sequence()` in `adam.odin`)
- ✅ Timer interrupt system sets `redraw_flag` for buffer swaps
- ✅ Main kernel loop handles buffer swapping on timer interrupts

### 🚧 **Missing Component: Display Output**

The **critical missing piece** is the display mapping function. Currently:

- Graphics render correctly to memory buffers
- `swap_buffers()` copies data between buffers
- **No connection exists between `FBUFFER` and QEMU's display**

---

## The Display Problem

### Current QEMU Configuration

```bash
# build.sh run_qemu()
qemu-system-riscv64 \
    -device virtio-gpu-pci \
    -display cocoa \
    # ... other options
```

### Issues Identified

1. **No framebuffer mapping function**: Missing `map_framebuffer_to_display()`
2. **VirtIO GPU not initialized**: Device present but not configured
3. **Display shows blank screen**: QEMU window opens but no graphics appear

---

## Implementation Plan

### **Step 1: Add Display Mapping Function**

Add to `tabris.odin`:

```odin
VIRTIO_GPU_FB_BASE :: 0x50000000  // VirtIO GPU framebuffer address

map_framebuffer_to_display :: proc() {
    // Map FBUFFER to QEMU display memory
    display_fb := cast([^]u32)(uintptr(VIRTIO_GPU_FB_BASE))

    // Copy front buffer to display memory
    for i in 0 ..< BUFFER_SIZE {
        display_fb[i] = FBUFFER[i]
    }
}
```

### **Step 2: Integrate Display Mapping**

Modify `swap_buffers()` in `tabris.odin`:

```odin
swap_buffers :: proc() {
    // Copy back buffer to front buffer
    for i in 0 ..< BUFFER_SIZE {
        FBUFFER[i] = BBUFFER[i]
    }

    // Send front buffer to display
    map_framebuffer_to_display()
}
```

### **Step 3: VirtIO GPU Detection (Optional Enhancement)**

Add to `lilith.odin`:

```odin
setup_virtio_gpu :: proc() {
    terminal_write("Initializing VirtIO GPU...\n")
    // PCI device detection and configuration
    // Set up proper framebuffer memory mapping
}
```

### **Step 4: Alternative Simple Framebuffer**

If VirtIO GPU proves complex, try simpler approach in QEMU:

```bash
# Alternative QEMU configuration
-device ramfb,width=640,height=480
```

---

## Testing Strategy

### Phase 1: Verify Current System

1. ✅ Confirm boot sequence renders text to buffers
2. ✅ Verify `swap_buffers()` copies data correctly
3. 🚧 Add display mapping and test QEMU GUI output

### Phase 2: Display Integration

1. Implement `map_framebuffer_to_display()`
2. Test with `./build.sh --run`
3. Verify text appears in QEMU window

### Phase 3: Optimization

1. Verify 60 FPS timer interrupts work correctly
2. Test smooth text rendering without flicker
3. Optimize memory copy operations if needed

---

## Expected Behavior After Fix

1. **Boot sequence**: Text renders to back buffer via `draw_string()`
2. **Buffer swap**: `swap_buffers()` copies to front buffer and display
3. **QEMU display**: Window shows MAGIos boot messages graphically
4. **Timer updates**: 60 FPS redraws for smooth animation

---

## Current Status Summary

| Component           | Status         | Notes                          |
| ------------------- | -------------- | ------------------------------ |
| Framebuffer Arrays  | ✅ Complete    | FBUFFER/BBUFFER allocated      |
| Text Rendering      | ✅ Complete    | draw_string() fully functional |
| Buffer Swapping     | ✅ Complete    | Memory-to-memory copy works    |
| Timer Interrupts    | ✅ Complete    | 60 FPS redraw_flag system      |
| **Display Mapping** | ❌ **MISSING** | **Critical blocker**           |
| QEMU Configuration  | ✅ Complete    | VirtIO GPU device present      |

---

## Immediate Next Steps

1. **Implement `map_framebuffer_to_display()` function**
2. **Add display mapping call to `swap_buffers()`**
3. **Test with `./build.sh --run` to verify GUI output**
4. **Debug memory mapping if display remains blank**

The rendering system is **architecturally complete** - only the final display output step needs implementation.

---

_Last Updated: Based on current implementation analysis_
_Critical Issue: Missing display mapping function_
