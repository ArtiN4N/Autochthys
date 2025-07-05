package src

import log "core:log"

Line :: struct {
    a, b: FVector
}

LINE_ZERO :: Line{{0,0},{0,0}}

cap_negative_line_coords :: proc(l: Line) -> Line {
    line := l
    if line.a.x < 0 { line.a.x = 0 }
    if line.b.x < 0 { line.b.x = 0 }
    if line.a.y < 0 { line.a.y = 0 }
    if line.b.y < 0 { line.b.y = 0 }

    return line
}
get_line_midpoint :: proc(l: Line) -> FVector {
    return { (l.a.x + l.b.x) / 2, (l.a.y + l.b.y) / 2 }
}
@(require_results)
get_line_slope :: proc(l: Line) -> (result: f32, ok: bool) {
    num := l.b.y - l.a.y
    denom := l.b.x - l.a.x

    if denom == 0 { return 0, false }

    return num / denom, true
}
lines_collide :: proc(i, j: Line) -> bool {
    q := i.a
    s := i.b - q
    p := j.a
    r := j.b - p

    denom := vector_cross(r, s)
    if denom == 0 { return i == j}

    t := vector_cross(q - p, s) / denom
    u := vector_cross(q - p, r) / denom

    return (0 <= t && t <= 1) && (0 <= u && u <= 1)

}
line_intersects_rect :: proc(l: Line, r: Rect) -> bool {
    // if line endpoint is contained within tile
    if rect_contains_vec(r, l.a) || rect_contains_vec(r, l.b) { return true }
    for rl in get_rect_lines(r) {
        if lines_collide(l, rl) { return true }
    }

    return false
}
line_vector_distance :: proc(l: Line, v: FVector) -> f32 {
    slope_1, slope_exists := get_line_slope(l)
    d1 : f32
    line_x : f32
    line_y : f32

    if slope_exists && slope_1 != 0 {
        slope_2 := -1 / slope_1
        line_x = ((slope_1 * f32(l.a.x) - f32(l.a.y)) - (slope_2 * f32(v.x) - f32(v.y))) / (slope_1 - slope_2)
        line_y = slope_1 * line_x - slope_1 * f32(l.a.x) + f32(l.a.y)
    } else if slope_exists && slope_1 == 0 {
        // horizontal line
        xmin := min(l.a.x, l.b.x)
        xmax := max(l.a.x, l.b.x)
        if xmin <= v.x && v.x <= xmax {
            return vector_dist(v, FVector{v.x, l.a.y})
        }
    } else {
        // vertical line
        ymin := min(l.a.y, l.b.y)
        ymax := max(l.a.y, l.b.y)
        if ymin <= v.y && v.y <= ymax {
            return vector_dist(v, FVector{l.a.x, v.y})
        }
    }
    
    d1 = vector_dist(v, FVector{line_x, line_y})
    contain_x := line_x < f32(max(l.a.x, l.b.x)) && line_x > f32(min(l.a.x, l.b.x))
    contain_y := line_y < f32(max(l.a.y, l.b.y)) && line_y > f32(min(l.a.y, l.b.y))

    if contain_x && contain_y { return d1 }

    d2 := vector_dist(v, l.a)
    d3 := vector_dist(v, l.b)

    return min(d2, d3)
}
line_circle_distance :: proc(l: Line, c: Circle) -> f32 {
    return max(line_vector_distance(l, get_circle_pos(c)) - c.r, 0)
}
line_intersects_circle :: proc(l: Line, c: Circle) -> bool {
    return line_circle_distance(l, c) <= 0
}
lines_distance :: proc(a: Line, b: Line) -> f32 {
    if lines_collide(a, b) { return 0 }

    return min(line_vector_distance(b, a.a), line_vector_distance(b, a.b), line_vector_distance(a, b.a), line_vector_distance(a, b.b))
}
line_rectangle_distance :: proc(a: Line, b: Rect) -> f32 {
    if rect_contains_vec(b, a.a) || rect_contains_vec(b, a.b) { return 0 }
    bl := get_rect_lines(b)
    return min(lines_distance(a, bl[.NO]), lines_distance(a, bl[.EA]), lines_distance(a, bl[.SO]), lines_distance(a, bl[.WE]))
}