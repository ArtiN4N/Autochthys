package src

import log "core:log"
import fmt "core:fmt"
import math "core:math"

LEVEL_check_line_collides :: proc(line: Line, level: ^Level) -> bool {
    min_bound, max_bound := LEVEL_get_coords_real_positions_are_bound_by(line.a, line.b)

    for x := min_bound.x; x <= max_bound.x; x += 1 {
        for y := min_bound.y; y <= max_bound.y; y += 1 {
            tile_rect := LEVEL_get_rect_from_coords(x, y)

            if line_intersects_rect(line, tile_rect) && LEVEL_get_coords_collision_bit(level, x, y) {
                return true
            }
        }
    }
    return false
}

LEVEL_check_circle_collides :: proc(cir: Circle, level: ^Level) -> bool {
    level_pos := LEVEL_convert_real_position_to_coords(get_circle_pos(cir))

    min_x := level_pos.x
    max_x := level_pos.x

    min_y := level_pos.y
    max_y := level_pos.y

    remainder := FVector{cir.x - f32(level_pos.x) * LEVEL_TILE_SIZE, cir.y - f32(level_pos.y) * LEVEL_TILE_SIZE}

    if remainder.x <= cir.r { min_x -= 1 }
    if remainder.x + cir.r >= LEVEL_TILE_SIZE { max_x += 1 }

    if remainder.y <= cir.r { min_y -= 1 }
    if remainder.y + cir.r >= LEVEL_TILE_SIZE { max_y += 1 }

    min_x = max(0, min_x)
    max_x = min(LEVEL_WIDTH - 1, max_x)

    min_y = max(0, min_y)
    max_y = min(LEVEL_HEIGHT - 1, max_y)

    for x := min_x; x <= max_x; x += 1 {
        for y := min_y; y <= max_y; y += 1 {
            tile_rect := LEVEL_get_rect_from_coords(x, y)

            if circle_collides_rect(cir, tile_rect) && LEVEL_get_coords_collision_bit(level, x, y) {
                return true
            }
        }
    }

    return false
}

LEVEL_check_circle_movement_collides :: proc(cir: Circle, move_pos: FVector, level: ^Level) -> bool {
    cir_2 := Circle{move_pos.x, move_pos.y, cir.r}
    line := Line{ get_circle_pos(cir), get_circle_pos(cir_2) }
    
    min_bound, max_bound := LEVEL_get_coords_real_positions_are_bound_by(line.a, line.b)

    // this is lazy but the alternative is so fucking lazy and really not even efficient ill just do this
    extra_check := u32(math.ceil(cir.r / LEVEL_TILE_SIZE))

    if extra_check > min_bound.x { min_bound.x = 0}
    else { min_bound.x -= extra_check }

    if extra_check + max_bound.x >= LEVEL_WIDTH { max_bound.x = LEVEL_WIDTH - 1 }
    else { max_bound.x += extra_check }

    if extra_check > min_bound.y { min_bound.y = 0}
    else { min_bound.y -= extra_check }

    if extra_check + max_bound.y >= LEVEL_HEIGHT { max_bound.y = LEVEL_HEIGHT - 1 }
    else { max_bound.y += extra_check }

    for x := min_bound.x; x <= max_bound.x; x += 1 {
        for y := min_bound.y; y <= max_bound.y; y += 1 {
            tile_rect := LEVEL_get_rect_from_coords(x, y)

            if line_rectangle_distance(line, tile_rect) <= cir.r && LEVEL_get_coords_collision_bit(level, x, y) {
                return true
            }
        }
    }
    return false
}

LEVEL_check_rect_collides :: proc(rect: Rect, level: ^Level) -> bool {
    corners := get_rect_corners(rect)
    min_bound, max_bound := LEVEL_get_coords_real_positions_are_bound_by(corners[.NW], corners[.SE])

    for x := min_bound.x; x <= max_bound.x; x += 1 {
        for y := min_bound.y; y <= max_bound.y; y += 1 {
            tile_rect := LEVEL_get_rect_from_coords(x, y)

            if rects_collide(rect, tile_rect) && LEVEL_get_coords_collision_bit(level, x, y) {
                return true
            }
        }
    }

    return false
}

LEVEL_check_rect_movement_collides :: proc(rect: Rect, p_pos: FVector, level: ^Level) -> bool {
    if get_rect_pos(rect) == p_pos { return false }

    rect := rect
    p_rect := rect_with_vector(rect, p_pos)
    if LEVEL_check_rect_collides(p_rect, level) { return true }

    corners := get_rect_corners(rect)
    p_corners := get_rect_corners(p_rect)

    if LEVEL_check_line_collides(Line{corners[.NE], p_corners[.NE]}, level) { return true }
    if LEVEL_check_line_collides(Line{corners[.NW], p_corners[.NW]}, level) { return true }
    if LEVEL_check_line_collides(Line{corners[.SW], p_corners[.SW]}, level) { return true }
    if LEVEL_check_line_collides(Line{corners[.SE], p_corners[.SE]}, level) { return true }

    max_x_rect_corners: ^RectCorners
    min_x_rect_corners: ^RectCorners
    max_y_rect_corners: ^RectCorners
    min_y_rect_corners: ^RectCorners

    if corners[.NE].x > p_corners[.NE].x { max_x_rect_corners = &corners }
    else                                 { max_x_rect_corners = &p_corners }

    if corners[.SW].x < p_corners[.SW].x { min_x_rect_corners = &corners }
    else                                 { min_x_rect_corners = &p_corners }

    if corners[.SW].y > p_corners[.SW].y { max_y_rect_corners = &corners }
    else                                 { max_y_rect_corners = &p_corners }

    if corners[.NE].y < p_corners[.NE].y { min_y_rect_corners = &corners }
    else                                 { min_y_rect_corners = &p_corners }

    max_x_sample := LEVEL_convert_real_position_to_coords(max_x_rect_corners[.NE]).x
    min_x_sample := LEVEL_convert_real_position_to_coords(min_x_rect_corners[.SW]).x
    max_y_sample := LEVEL_convert_real_position_to_coords(max_y_rect_corners[.SW]).y
    min_y_sample := LEVEL_convert_real_position_to_coords(min_y_rect_corners[.NE]).y

    min_bound := TVector{min_x_sample, min_y_sample}
    max_bound := TVector{max_x_sample, max_y_sample}

    edge_line_a, mid_line, edge_line_b := get_rect_movement_defining_lines(rect, p_pos)
    max_d := lines_distance(edge_line_a, edge_line_b)

    for x := min_bound.x; x <= max_bound.x; x += 1 {
        for y := min_bound.y; y <= max_bound.y; y += 1 {
            tile_rect := LEVEL_get_rect_from_coords(x, y)

            if !line_intersects_rect(mid_line, tile_rect) {
                if line_rectangle_distance(edge_line_a, tile_rect) > max_d || line_rectangle_distance(edge_line_b, tile_rect) > max_d {
                    continue
                }
            }

            if LEVEL_get_coords_collision_bit(level, x, y) {
                return true
            }
        }
    }

    return false
}