package core

import "../glyphs"

//Tabris is the angel Shinji kills with Unit-01 at the end of the show, he is essentially the last angel of the series, also known as Kaworu

//Display
RES_X :: 640
RES_Y :: 480

//Cursors position for drawing text
posx: u16 = 40
posy: u16 = 40

//Size of screen buffer in a 1D array (which honestly feels kinda odd but I'm sure is very performant
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
	//where in the array are we looking for the bites to draw.
	byte_offset := 0
	for i in 0 ..< 16 {
		start_x := posx //So we can reset after each row.

		//font is 16x16, hopefully not subject to change, so basically 2 bytes per row of font character
		byte_1 := character[byte_offset]
		byte_2 := character[byte_offset + 1]
		byte_offset += 2

		//first byte
		for bit1 in 0 ..< 8 {
			// use and to check value, use << to check the next byte and then use the bit1 to shift which bit is being checked....simples? if its on, draw a pixel.
			if (byte_1 & (1 << (7 - u8(bit1)))) != 0 {
				update_pixel(posx, posy, white)
				posx += 1 //move to next position
			} else {
				posx += 1
			}
		}

		//second byte, same shit
		for bit2 in 0 ..< 8 {
			if (byte_2 & (1 << (7 - u8(bit2)))) != 0 {
				update_pixel(posx, posy, white)
				posx += 1
			} else {
				posx += 1
			}
		}

		//after each row, move down one.
		posy += 1
		//reset x to start.
		posx := start_x
	}
	// Need to implement new line.
	posy := (posy - 16)
}

//Gets byte array from inconsolata array and then runs through the function to draw the string into the back buffer.
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
