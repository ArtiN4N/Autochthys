package src

import "core:math"
import "core:log"

Circle :: struct { x, y, r: f32 }

get_circle_pos :: proc(c: Circle) -> FVector {
    return { c.x, c.y }
}
get_circle_cum :: proc(c: Circle) -> f32 {
    return 2 * math.PI * c.r
}
circle_add_vec :: proc(a: Circle, b: FVector) -> Circle {
    return {a.x + b.x, a.y + b.y, a.r}
}
circle_vec_dist :: proc(a: Circle, b: FVector) -> f32 {
    return max(vector_dist(b, get_circle_pos(a)) - a.r, 0)
}
circles_collide :: proc(a: Circle, b: Circle) -> bool {
    return vector_dist(get_circle_pos(a), get_circle_pos(b)) <= a.r + b.r
}
circle_rect_dist :: proc(a: Circle, b: Rect) -> f32 {
    rc := get_rect_corners(b)

    test_x := a.x
    test_y := a.y

    if a.x < rc[.NW].x { test_x = rc[.NW].x }
    else if a.x > rc[.NE].x { test_x = rc[.NE].x }

    if a.y < rc[.NE].y { test_y = rc[.NE].y }
    else if a.y > rc[.SE].y { test_y = rc[.SE].y }

    d_x := a.x - test_x
    d_y := a.y - test_y
    return max(0, vector_dist(FVector{d_x, d_y}, FVECTOR_ZERO) - a.r)
}
circle_collides_rect :: proc(a: Circle, b: Rect) -> bool {
    return circle_rect_dist(a, b) <= 0
}