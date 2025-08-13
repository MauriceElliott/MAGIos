package virtues

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
	copy(buffer[:], a)
	copy(buffer[len(a):], b)
	return string(buffer[:result_len])
}
