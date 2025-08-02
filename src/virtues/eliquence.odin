package virtues

int_to_string :: proc(num: int) -> string {
	// Buffer large enough for 32-bit int plus sign
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


//TODO: Change to coal() for Coalesce, sounds sexier and matches the edgy vibe of MAGIos
concat :: proc(a: string, b: string) -> string {
	// Buffer large enough for both strings
	buffer: [256]u8
	result_len := len(a) + len(b)
	if result_len > len(buffer) {
		return "" // Return empty string if too long
	}

	// Copy first string
	for i in 0 ..< len(a) {
		buffer[i] = a[i]
	}

	// Copy second string
	for i in 0 ..< len(b) {
		buffer[len(a) + i] = b[i]
	}

	// Return a slice so as to avoid unnecessary memory allocation
	return string(buffer[:result_len])
}
