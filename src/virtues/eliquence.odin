package virtues

stringify :: proc(num: $T) -> string {
	buffer: [12]u8

	when T == int {
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
	} else when T == u8 {
		// Handle zero case
		if num == 0 {
			buffer[0] = '0'
			return string(buffer[:1])
		}

		// Convert digits
		temp := num
		digit_count := 0

		// Count digits and extract them (in reverse order)
		for temp > 0 {
			if digit_count >= len(buffer) do break
			digit := temp % 10
			buffer[digit_count] = u8('0' + digit)
			temp /= 10
			digit_count += 1
		}

		// Reverse the string to get correct order
		for i in 0 ..< digit_count / 2 {
			j := digit_count - 1 - i
			buffer[i], buffer[j] = buffer[j], buffer[i]
		}

		return string(buffer[:digit_count])
	} else {
		// Fallback for unsupported types
		return ""
	}
}

coal :: proc(a: string, b: string) -> string {
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
