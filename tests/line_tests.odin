package tests

import g4n "../src"
import log "core:log"
import math "core:math"
import testing "core:testing"

@(test)
line_mid_test :: proc(t: ^testing.T) {
    using g4n
    a := Line{{-1.7,5.6}, {4.0, 5.5}}

    testing.expect_value(t, g4n.get_line_midpoint(a), g4n.FVector{1.15,5.55})
}

@(test)
cap_negative_line_test :: proc(t: ^testing.T) {
    using g4n
    a := Line{{-10.7,5.6}, {4.0, 5.5}}

    testing.expect_value(t, g4n.cap_negative_line_coords(a), g4n.Line{{0,5.6}, {4.0, 5.5}})
}

@(test)
line_collision_test :: proc(t: ^testing.T) {
    using g4n
    a := Line{{-1.7,5.5}, {4.0, 5.6}}
    b := Line{{-1.7,5.5}, {-4.0, -5.6}}

    c := Line{{10, 10}, {2,2}}
    d := Line{{10, 12}, {2,3}}

    testing.expect(t, g4n.lines_collide(a,b))
    testing.expect(t, !g4n.lines_collide(c,d))
}

@(test)
line_rect_intersect_test :: proc(t: ^testing.T) {
    using g4n
    a := Line{{-1.7,5.6}, {4.0, 5.5}}

    b := Rect{-2, 2, 3, 5}
    c := Rect{-1, 3, 2, 2}

    testing.expect(t, g4n.line_intersects_rect(a,b))
    testing.expect(t, !g4n.line_intersects_rect(a,c))
}

@(test)
line_vector_dist_test :: proc(t: ^testing.T) {
    using g4n
    a := g4n.Line{{5,5}, g4n.FVECTOR_ZERO}

    testing.expect_value(t, g4n.line_vector_distance(a, g4n.get_line_midpoint(a)), 0)
    testing.expect_value(t, g4n.line_vector_distance(a, a.a), 0)
    testing.expect_value(t, g4n.line_vector_distance(a, a.b), 0)
    testing.expect_value(t, g4n.line_vector_distance(a, FVector{5,7}), 2)
    testing.expect_value(t, g4n.line_vector_distance(a, FVector{6,0}), math.sqrt_f32(18))
    testing.expect_value(t, g4n.line_vector_distance(a, FVector{6,4}), math.sqrt_f32(2))
    testing.expect_value(t, g4n.line_vector_distance(a, FVector{8,4}), math.sqrt_f32(10))
}

@(test)
line_circle_dist_test :: proc(t: ^testing.T) {
    using g4n
    b := Line{{-1.7,5.6}, {4.0, 5.5}}
    k := Circle{1.15, 5.85, 0.003}

    testing.expect(t, abs(g4n.line_circle_distance(b, k) - math.sqrt_f32(0.089973696744) + 0.003) < 0.0001)
}

@(test)
line_circle_collide_test :: proc(t: ^testing.T) {
    using g4n
    a := Line{{5,5}, FVECTOR_ZERO}
    d := Circle{2, 2, 1}
    e := Circle{5, 5, 1}
    f := Circle{0, 0, 1}
    g := Circle{5, 7, 1}
    h := Circle{6, 0, 4}
    i := Circle{6, 4, 2}
    j := Circle{8, 4, 4}

    testing.expect(t, g4n.line_intersects_circle(a, d))
    testing.expect(t, g4n.line_intersects_circle(a, e))
    testing.expect(t, g4n.line_intersects_circle(a, f))
    testing.expect(t, !g4n.line_intersects_circle(a, g))
    testing.expect(t, !g4n.line_intersects_circle(a, h))
    testing.expect(t, g4n.line_intersects_circle(a, i))
    testing.expect(t, g4n.line_intersects_circle(a, j))
}
@(test)
lines_dist_test :: proc(t: ^testing.T) {
    using g4n
    a := Line{{5,5}, {4,4}}
    b := Line{{-2,0}, {7,1}}
    c := Line{{-1.7,5.5}, {4.0, 5.6}}
    d := Line{{-17.8,5.8}, {-4.0, -5.6}}

    testing.expect_value(t, g4n.lines_distance(a,a), 0)
    testing.expect(t, abs(g4n.lines_distance(a,b) - math.sqrt_f32(10.9755878049)) < 0.0001)
    testing.expect(t, abs(g4n.lines_distance(c,d) - math.sqrt_f32(100.45056)) < 0.0001)
}

@(test)
line_rect_dist_test :: proc(t: ^testing.T) {
    using g4n
    a := Rect{1, -4, 5, 15}
    d := Line{{3, 12}, {3, -6}}
    e := Line{{3, 9}, {3, 8}}
    f := Line{{1, 10}, {5, 10}}
    g := Line{{3, 15}, {3, 12}}

    testing.expect_value(t, g4n.line_rectangle_distance(d, a), 0)
    testing.expect_value(t, g4n.line_rectangle_distance(e, a), 0)
    testing.expect_value(t, g4n.line_rectangle_distance(f, a), 0)
    testing.expect_value(t, g4n.line_rectangle_distance(g, a), 2)

}