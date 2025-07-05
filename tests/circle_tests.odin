package tests

import g4n "../src"
import math "core:math"
import testing "core:testing"

@(test)
circle_circumf_test :: proc(t: ^testing.T) {
    using g4n
    a := Circle{0, 0, 4.78}

    testing.expect(t, abs(get_circle_cum(a) - 9.56 * math.PI) < 0.0001)
}

@(test)
circle_add_vec_test :: proc(t: ^testing.T) {
    using g4n
    a := Circle{0, 0, 4.78}

    testing.expect_value(t, get_circle_pos(circle_add_vec(a, FVector{4, -10.6})), FVector{4, -10.6})
}

@(test)
circle_vec_dist_test :: proc(t: ^testing.T) {
    using g4n
    a := Circle{0, 0, 4.78}

    testing.expect(t, abs(circle_vec_dist(a, FVector{4, -10.6}) - math.sqrt_f32(128.36) + 4.78) < 0.0001)
}

@(test)
circles_collide_test :: proc(t: ^testing.T) {
    using g4n
    a := Circle{0, 0, 10}
    b := Circle{20, 0, 10}
    c := Circle{0, 0, 9.999}

    testing.expect(t, circles_collide(a, b))
    testing.expect(t, !circles_collide(b, c))
}

@(test)
circle_rect_dist_test :: proc(t: ^testing.T) {
    using g4n
    a := Circle{4, 4, 1}
    b := Rect{6, 1, 2, 3}
    testing.expect_value(t, g4n.circle_rect_dist(a, b), 1.236068)
}

@(test)
circle_rect_collides_test :: proc(t: ^testing.T) {
    using g4n
    a := g4n.Circle{0, -5, 3}
    b := g4n.Rect{0, -5, 1, 1}

    testing.expect(t, g4n.circle_collides_rect(a, b))
}