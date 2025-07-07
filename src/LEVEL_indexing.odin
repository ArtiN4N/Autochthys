package src

import log "core:log"

LEVEL_check_out_of_bounds :: proc(x, y: i32, width, height: u8) -> bool {
    return x < 0 || x >= i32(width) || y < 0 || y >= i32(height)
}

LEVEL_convert_real_position_to_coords :: proc(vec: FVector) -> IVector {
    scaled := vector_div_scalar(vec, LEVEL_TILE_SIZE)
    floored := floor_fvector(scaled)

    discrete := to_ivector(floored)

    return discrete
}

// a real rect is "bound" by a minimum and maximum x and y coordinate
// in other words, if we find which level cell the north west corner of a rect is in,
// as well as which cell the south east is in,
// we can then iterate over every level cell that the rectangle is touching
LEVEL_get_coords_real_positions_are_bound_by :: proc(a, b: FVector) -> (min_v, max_v: IVector) {
    a_bounds := LEVEL_convert_real_position_to_coords(a)
    b_bounds := LEVEL_convert_real_position_to_coords(b)

    min_v = IVector{ min(a_bounds.x, b_bounds.x), min(a_bounds.y, b_bounds.y) }
    max_v = IVector{ max(a_bounds.x, b_bounds.x), max(a_bounds.y, b_bounds.y) }

    return min_v, max_v
}

LEVEL_get_rect_from_coords :: proc(x, y: i32) -> Rect {
    return Rect{f32(x) * LEVEL_TILE_SIZE, f32(y) * LEVEL_TILE_SIZE, LEVEL_TILE_SIZE, LEVEL_TILE_SIZE}
}

// simple level collision data is stored in a byte array.
// each byte stores the collision data for 8 level cells
// therefore, each bit represents a level cell, with 1 meaning the cell has collision
LEVEL_get_coords_collision_bit :: proc(level: ^Level, x, y: i32) -> bool {
    if LEVEL_check_out_of_bounds(x, y, LEVEL_WIDTH, LEVEL_HEIGHT) {
        //log.logf(.Warning, "Trying to access map out of bounds")
        return true
    }

    return level.collision_map[x][y]
}

// basically for all warp positions being stored (enemy spawns, player warps on entering levels)
LEVEL_get_tile_warp_as_real_position :: proc(pos: [2]i32) -> FVector {
    return FVector{ f32(pos.x) * LEVEL_TILE_SIZE + LEVEL_TILE_SIZE / 2, f32(pos.y) * LEVEL_TILE_SIZE + LEVEL_TILE_SIZE / 2 }
}