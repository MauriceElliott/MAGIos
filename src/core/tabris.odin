package core

import "../glyphs"

//Display
RES_X :: 640
RES_Y :: 480
posx: u16 = 40
posy: u16 = 40
BUFFER_SIZE :: RES_X * RES_Y
// Colourmode uses an unsigned 32bit integer to allow for 32bit RGBA
FBUFFER: [BUFFER_SIZE]u32
BBUFFER: [BUFFER_SIZE]u32

white :: 0xFFFFFFFF
black :: 0xFF000000

//font fidelity (16x16)
BYTES_PER_GLYPH :: 32
BYTES_FOR_OFFSET :: 32

update_pixel :: proc(x: u16, y: u16, colour: u32) {
	BBUFFER[x + y * RES_X] = colour
}

draw_rune_with_magic :: proc(character: []u8) {
	byte_offset := 0
	for i in 0 ..< 16 {
		byte_1 := character[byte_offset]
		byte_2 := character[byte_offset + 1]
		byte_offset += 2

		for bit1 in 0 ..< 8 {
			if (byte_1 & (1 << (7 - u8(bit1)))) != 0 {
				update_pixel(posx, posy, white)
				posx += 1
			} else {
				posx += 1
			}
		}

		for bit2 in 0 ..< 8 {
			if (byte_2 & (1 << (7 - u8(bit2)))) != 0 {
				update_pixel(posx, posy, white)
				posx += 1
			} else {
				posx += 1
			}
		}
		posy += 1
	}
	posy := (posy - 16)
}

//May get included in the glyph array as a struct, but no need right now, only have a single font.

draw_string :: proc(text: string) -> bool {
	for character, c_index in text {
		glyph_index := int(character)
		glyph_start := (glyph_index * BYTES_PER_GLYPH) + BYTES_FOR_OFFSET

		if glyph_start + BYTES_PER_GLYPH > len(glyphs.inconsolata_16x16_font) do continue
		draw_rune_with_magic(
			glyphs.inconsolata_16x16_font[glyph_start:glyph_start + BYTES_PER_GLYPH],
		)
	}
	return true
}
