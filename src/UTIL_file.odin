package src

import strings "core:strings"

// The resultant string must have its memory freed
UTIL_create_filepath_A :: proc(args: ..string) -> string {
    return strings.concatenate(args)
}

// strings that have null bytes before the end cause problems
// so we use this to shorten them
// we take raw char data as an input,
// since this only really happens when reading fixed length strings from files
UTIL_string_from_char_data :: proc(data: []u8) -> string {
    ret: string

    valid_string_bytes := 0
    for b in data { if b != 0x0 { valid_string_bytes += 1 } }

    ret = string(data[:valid_string_bytes])

    return ret
}