package tests

import game "../src"
import math "core:math"
import testing "core:testing"

@(test)
correct_circle_col_test :: proc(t: ^testing.T) {
    using game

    lcol: LEVEL_Collision

    fpath := UTIL_create_filepath_A("data/levels/", LEVEL_tag_files[.Crosshair])
    LEVEL_load_data(&lcol, fpath)
    delete(fpath)

    opos := LEVEL_convert_coords_to_real_position({3,4})

    test_circle := Circle{opos.x, opos.y, 5}
    new_position := LEVEL_convert_coords_to_real_position({1,1})

    cpos, cx, cy := LEVEL_correct_circle_collision(test_circle, new_position, &lcol)

    testing.expect_value(t, cpos, new_position)
    testing.expect_value(t, cx, false)
    testing.expect_value(t, cy, false)




    opos = LEVEL_convert_coords_to_real_position({3,4})

    test_circle = Circle{opos.x, opos.y, 5}
    new_position = LEVEL_convert_coords_to_real_position({3,5})

    cpos, cx, cy = LEVEL_correct_circle_collision(test_circle, new_position, &lcol)

 
    testing.expect_value(t, cx, false)
    testing.expect_value(t, cy, true)
}