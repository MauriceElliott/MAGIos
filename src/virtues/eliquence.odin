package virtues

import "glyphs"

u64_stringify :: proc(num: u64) -> string {
	buffer: [12]u8
	i := len(buffer)
	neg := false
	n := num
	if n < 0 {
		neg = true
		n = -n
	}
	if n == 0 {
		i -= 1
		buffer[i] = '0'
	}
	for n > 0 {
		i -= 1
		buffer[i] = '0' + u8(n % 10)
		n /= 10
	}
	if neg {
		i -= 1
		buffer[i] = '-'
	}
	return string(buffer[i:])
}

int_stringify :: proc(num: int) -> string {
	buffer: [12]u8
	i := len(buffer)
	neg := false
	n := num
	if n < 0 {
		neg = true
		n = -n
	}
	if n == 0 {
		i -= 1
		buffer[i] = '0'
	}
	for n > 0 {
		i -= 1
		buffer[i] = '0' + u8(n % 10)
		n /= 10
	}
	if neg {
		i -= 1
		buffer[i] = '-'
	}
	return string(buffer[i:])
}

u8_stringify :: proc(num: u8) -> string {
	buffer: [12]u8
	if num == 0 {
		buffer[0] = '0'
		return string(buffer[:1])
	}
	temp := num
	digit_count := 0
	for temp > 0 {
		if digit_count >= len(buffer) do break
		digit := temp % 10
		buffer[digit_count] = u8('0' + digit)
		temp /= 10
		digit_count += 1
	}
	for i in 0 ..< digit_count / 2 {
		j := digit_count - 1 - i
		buffer[i], buffer[j] = buffer[j], buffer[i]
	}
	return string(buffer[:digit_count])
}

stringify :: proc {
	u64_stringify,
	int_stringify,
	u8_stringify,
}

coal :: proc(a: string, b: string) -> string {
	buffer: [256]u8
	result_len := len(a) + len(b)
	if result_len > len(buffer) {
		return ""
	}
	for i in 0 ..< len(a) {
		buffer[i] = a[i]
	}
	for i in 0 ..< len(b) {
		buffer[len(a) + i] = b[i]
	}
	return string(buffer[:result_len])
}

//May get included in the glyph array as a struct, but no need right now, only have a single font.
BYTES_PER_GLYPH :: 32

string_to_psf_buffer :: proc(text: string, buffer: [][]u8) -> int {
	if len(text) > len(buffer) do return -1
	count := 0
	for character, c_index in text {
		glyph_index := int(character)
		glyph_start := glyph_index * BYTES_PER_GLYPH

		if glyph_start + BYTES_PER_GLYPH > len(glyphs.inconsolata_16x16_font) do continue
		if len(buffer[c_index]) < BYTES_PER_GLYPH do continue

		copy(
			buffer[c_index],
			glyphs.inconsolata_16x16_font[glyph_start:glyph_start + BYTES_PER_GLYPH],
		)
		count += 1
	}
	return count
}
