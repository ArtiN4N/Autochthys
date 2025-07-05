package src

import rl "vendor:raylib"
import log "core:log"
import math "core:math"

Rect :: struct {x,y,w,h: f32}

RECT_ZERO :: Rect{0,0,0,0}

RectCornerNames :: enum{ NW = 0, NE, SE, SW }
RectLineNames :: enum{ NO = 0, EA, SO, WE }

RectCorners :: [RectCornerNames]FVector
RectLines   :: [RectLineNames]Line

to_rl_rect :: proc(r: Rect) -> rl.Rectangle {
    return {r.x, r.y, r.w, r.h}
}
rect_from_vecs :: proc(pos, size: FVector) -> Rect {
    return {pos.x, pos.y, size.x, size.y}
}
rect_with_vector :: proc(r: Rect, v: FVector) -> Rect {
    return {v.x, v.y, r.w, r.h}
}
get_rect_pos :: proc(r: Rect) -> FVector {
    return {r.x, r.y}
}
get_rect_size :: proc(r: Rect) -> FVector {
    return {r.w, r.h}
}
rect_add_vector :: proc(r: Rect, v: FVector) -> Rect {
    return {r.x + v.x, r.y + v.y, r.w, r.h}
}
get_rect_corners :: proc(r: Rect) -> RectCorners {
    return {
        .NW = {r.x,           r.y},
        .NE = {r.x + r.w - 1, r.y},
        .SE = {r.x + r.w - 1, r.y + r.h - 1},
        .SW = {r.x,           r.y + r.h - 1},
    }
}
get_rect_lines :: proc(r: Rect) -> RectLines {
    cs := get_rect_corners(r)
    return {
        .NO = {cs[.NW], cs[.NE]},
        .EA = {cs[.NE], cs[.SE]},
        .SO = {cs[.SE], cs[.SW]},
        .WE = {cs[.SW], cs[.NW]},
    }
}
rect_contains_vec :: proc(r: Rect, v: FVector) -> bool {
    cs := get_rect_corners(r)
    return v.x >= cs[.NW].x && v.x <= cs[.NE].x && v.y >= cs[.NE].y && v.y <= cs[.SE].y
}
rects_collide_non_pixels :: proc(r1, r2: Rect) -> bool {
    c1 := get_rect_corners(r1)
    c2 := get_rect_corners(r2)

    return c1[.NE].x >= c2[.NW].x && c1[.NW].x <= c2[.NE].x && c1[.SE].y >= c2[.NE].y && c1[.NE].y <= c2[.SE].y
}
rects_collide :: proc(r1, r2: Rect) -> bool {
    c1 := get_rect_corners(r1)
    c2 := get_rect_corners(r2)

    x_col := math.floor(c1[.NE].x) >= math.floor(c2[.NW].x) && math.floor(c1[.NW].x) <= math.floor(c2[.NE].x)
    y_col := math.floor(c1[.SE].y) >= math.floor(c2[.NE].y) && math.floor(c1[.NE].y) <= math.floor(c2[.SE].y)

    return x_col && y_col
}
//https://stackoverflow.com/a/26178015
// These procs get the closest distance between rectangle -- meaning, more detailed than just the difference in their positions
// if the centres of rect a and rect b have a distance of 5, then the rects are closer if they are diagonal to one another
rects_dist :: proc(r1, r2: Rect) -> f32 {
    c1 := get_rect_corners(r1)
    c2 := get_rect_corners(r2)

    b_is_left := c2[.NE].x < c1[.NW].x
    b_is_right := c2[.NW].x > c1[.NE].x
    b_is_bottom := c2[.NE].y > c1[.SE].y
    b_is_top := c2[.SE].y < c1[.NE].y

    if b_is_top && b_is_left          { return vector_dist(c2[.SE], c1[.NW]) }
    else if b_is_left && b_is_bottom  { return vector_dist(c2[.NE], c1[.SW]) }
    else if b_is_bottom && b_is_right { return vector_dist(c2[.NW], c1[.SE]) }
    else if b_is_right && b_is_top    { return vector_dist(c2[.SW], c1[.NE]) }
    else if b_is_left   { return abs(c2[.NE].x - c1[.NW].x) }
    else if b_is_right  { return abs(c2[.NW].x - c1[.NE].x) }
    else if b_is_bottom { return abs(c2[.NE].y - c1[.SE].y) }
    else if b_is_top    { return abs(c2[.SE].y - c1[.NE].y) }
    else { return 0 } // rects intersect
}
// Again, closest distance, so more than just the centre rect vector distance
rect_vector_dist :: proc(r: Rect, v: FVector) -> f32 {
    cs := get_rect_corners(r)

    axis_dist := FVector{
        max(cs[.NW].x - v.x, v.x - cs[.NE].x, 0),
        max(cs[.NE].y - v.y, v.y - cs[.SE].y, 0)
    }
    return vector_dist(axis_dist, FVECTOR_ZERO)
}
// Movement defining lines are the lines between thge corners of rect a, and the corners of modified rect a'
// The problem is that there are only 3 relevant lines: the line that intersects the centre of the rect,
// and the 2 lines on the edges of the rectangle.
// Which 2 lines are the edges depends on the movement direction of the rect.
// This procedure simply checks the direction of the rect's movement, and returns the correct movement defining lines.
get_rect_movement_defining_lines :: proc(r: Rect, pos: FVector) -> (edge_line_a, mid_line, edge_line_b: Line) {
    p_rect := r
    p_rect.x = pos.x
    p_rect.y = pos.y

    corners := get_rect_corners(r)
    p_corners := get_rect_corners(p_rect)

    direct_north_movement : bool = p_corners[.SW].y < corners[.SW].y && p_corners[.SW].x == corners[.SW].x && p_corners[.NE].x == corners[.NE].x
    direct_south_movement : bool = p_corners[.NW].y > corners[.NW].y && p_corners[.SW].x == corners[.SW].x && p_corners[.NE].x == corners[.NE].x

    direct_east_movement : bool = p_corners[.NW].x > corners[.NW].x && p_corners[.SW].y == corners[.SW].y && p_corners[.NE].y == corners[.NE].y
    direct_west_movement : bool = p_corners[.NE].x < corners[.NE].x && p_corners[.SW].y == corners[.SW].y && p_corners[.NE].y == corners[.NE].y

    if direct_north_movement {
        edge_line_a = Line{corners[.SW], p_corners[.NW]}
        edge_line_b = Line{corners[.SE], p_corners[.NE]}
        mid_line = Line{corners[.SE], p_corners[.NE]}

        return
    }
    if direct_south_movement {
        edge_line_a = Line{corners[.NW], p_corners[.SW]}
        edge_line_b = Line{corners[.NE], p_corners[.SE]}
        mid_line = Line{corners[.NE], p_corners[.SE]}

        return
    }
    if direct_east_movement {
        edge_line_a = Line{corners[.NW], p_corners[.NE]}
        edge_line_b = Line{corners[.SW], p_corners[.SE]}
        mid_line = Line{corners[.SW], p_corners[.SE]}

        return
    }
    if direct_west_movement {
        edge_line_a = Line{corners[.NE], p_corners[.NW]}
        edge_line_b = Line{corners[.SE], p_corners[.SW]}
        mid_line = Line{corners[.SE], p_corners[.SW]}

        return
    }

    NE_quadrant_movement : bool = p_corners[.SW].x > corners[.SW].x && p_corners[.SW].y < corners[.SW].y
    SW_quadrant_movement : bool = p_corners[.NE].x < corners[.NE].x && p_corners[.NE].y > corners[.NE].y
    SE_quadrant_movement : bool = p_corners[.SW].x > corners[.SW].x && p_corners[.NE].y > corners[.NE].y

    if NE_quadrant_movement {
        edge_line_a = Line{corners[.NW], p_corners[.NW]}
        edge_line_b = Line{corners[.SE], p_corners[.SE]}
        mid_line = Line{corners[.SW], p_corners[.NE]}

        return
    }

    if SW_quadrant_movement {
        edge_line_a = Line{corners[.NW], p_corners[.NW]}
        edge_line_b = Line{corners[.SE], p_corners[.SE]}
        mid_line = Line{corners[.NE], p_corners[.SW]}

        return
    }

    if SE_quadrant_movement {
        edge_line_a = Line{corners[.NE], p_corners[.NE]}
        edge_line_b = Line{corners[.SW], p_corners[.SW]}
        mid_line = Line{corners[.NW], p_corners[.SE]}

        return
    }

    // NW quadrant
    edge_line_a = Line{corners[.NE], p_corners[.NE]}
    edge_line_b = Line{corners[.SW], p_corners[.SW]}
    mid_line = Line{corners[.SE], p_corners[.NW]}

    return
}