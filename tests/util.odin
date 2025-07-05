package tests

import game "../src"
import testing "core:testing"

@(test)
create_filepath_test :: proc(t: ^testing.T) {
    using game

    fpath := UTIL_create_filepath_A("1", "2", "3")

    testing.expect_value(t, fpath, "123")
    delete(fpath)
}

@(test)
string_from_char_data_test :: proc(t: ^testing.T) {
    using game

    data: []u8 = {0x4a, 0x5b, 0x61, 0x00, 0x00} 
    str := UTIL_string_from_char_data(data)

    testing.expect_value(t, str, "J[a")
}