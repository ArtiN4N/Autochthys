package src

import log "core:log"

LEVEL_check_out_of_bounds :: proc(x, y: u32, width, height: u8) -> bool {
    // u32s so no need to check if less than 0
    return x >= u32(width) || y >= u32(height)
}

LEVEL_convert_real_position_to_coords :: proc(vec: FVector) -> TVector {
    scaled := vector_div_scalar(vec, LEVEL_TILE_SIZE)
    floored := floor_fvector(scaled)

    // if the original position had a negative coord, this would be an error
    // we expect any errors related to a negative position to be handled elsewhere
    // this is to prevent multiple out of bounds errors on the same frame
    // regardless, the logger will give a warning if the casted vector was negative
    // so we can still tell something is wrong if the error handling system is not working
    discrete := to_tvector(floored)

    return discrete
}

// a real rect is "bound" by a minimum and maximum x and y coordinate
// in other words, if we find which level cell the north west corner of a rect is in,
// as well as which cell the south east is in,
// we can then iterate over every level cell that the rectangle is touching
LEVEL_get_coords_real_positions_are_bound_by :: proc(a, b: FVector) -> (min_v, max_v: TVector) {
    a_bounds := LEVEL_convert_real_position_to_coords(a)
    b_bounds := LEVEL_convert_real_position_to_coords(b)

    min_v = TVector{ min(a_bounds.x, b_bounds.x), min(a_bounds.y, b_bounds.y) }
    max_v = TVector{ max(a_bounds.x, b_bounds.x), max(a_bounds.y, b_bounds.y) }

    return min_v, max_v
}

LEVEL_get_rect_from_coords :: proc(x, y: u32) -> Rect {
    return Rect{f32(x) * LEVEL_TILE_SIZE, f32(y) * LEVEL_TILE_SIZE, LEVEL_TILE_SIZE, LEVEL_TILE_SIZE}
}

// simple level collision data is stored in a byte array.
// each byte stores the collision data for 8 level cells
// therefore, each bit represents a level cell, with 1 meaning the cell has collision
LEVEL_get_coords_collision_bit :: proc(level: ^Level, x, y: u32) -> bool {
    // If the provided coords are out of bounds, the real error is not that we are checking the bit with them,
    // but that the position itself is out of bounds
    // thus we trust that this error is handled in a more appropriate location
    // and simply write a warning to the log
    if LEVEL_check_out_of_bounds(x, y, LEVEL_WIDTH, LEVEL_HEIGHT) {
        log.logf(.Warning, "Trying to access map out of bounds")
        return true
    }

    return level.collision_map[x][y]
}
