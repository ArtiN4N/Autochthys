package src

// https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle
point_in_triangle :: proc(p, a, b, c: FVector) -> bool {
    sign :: proc(p1, p2, p3: FVector) -> f32 {
        return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
    }

    d1 := sign(p, a, b)
    d2 := sign(p, b, c)
    d3 := sign(p, c, a)

    has_negative := d1 < 0 || d2 < 0 || d3 < 0
    has_positive := d1 > 0 || d2 > 0 || d3 > 0

    return !(has_negative && has_positive)
}

triangle_collides_circle :: proc(p: Circle, a, b, c: FVector) -> bool {
    if point_in_triangle(get_circle_pos(p), a, b, c) { return true }

    verts: [3]FVector = {a, b, c}
    for v in verts {
        if circle_vec_dist(p, v) == 0 {
            return true
        }
    }

    edges : [3]Line = {{a, b}, {b, c}, {c, a}}
    for e in edges {
        if line_circle_distance(e, p) == 0 {
            return true
        }
    }

    return false
}