package src

import log "core:log"
import fmt "core:fmt"
import math "core:math"

// something to implement:
// if we get a current rect, the desired rect it moves to,
// and find the min and max x and y for each
// then we can construct a rectangle that contains both rectangles
// then we can check if this rectangle collides with the map
// for easy collision detection

LEVEL_move_with_collision :: proc(position: ^FVector, new_position: FVector, radius: f32, level: ^Level) -> (collided_x, collided_y: bool) {
    cx, cy: bool
    cir := Circle{position.x, position.y, radius}

    position^, cx, cy = LEVEL_correct_circle_collision(cir, new_position, level)
    return cx, cy
}

LEVEL_correct_circle_collision :: proc(
    cir: Circle, new_position: FVector, level: ^Level
) -> (correct_pos: FVector, collided_x, collided_y: bool) {
    if (new_position == get_circle_pos(cir)) { return new_position, false, false }
    
    if (LEVEL_check_circle_collides(cir, level)) {
        return get_circle_pos(cir), true, true
    }
    if (!LEVEL_check_circle_movement_collides(cir, new_position, level)) { return new_position, false, false }
    return LEVEL_increment_circle_collision_correction(cir, new_position, level)
}

LEVEL_iterate_axis :: proc(ppos, opos, npos, sdiv: FVector, radius: f32, level: ^Level) -> (
    update_pos, update_sdiv: FVector,
    continue_iter, collided: bool,
) {
    continue_iter = true
    axis_x := sdiv.x != 0

    tppos := ppos + sdiv
    tcir := Circle{tppos.x, tppos.y, radius}

    if LEVEL_check_circle_collides(tcir, level) {
        nsdiv := vector_div_scalar(sdiv, 2)
        // if subdivison is too low, then we can assume were practically up against the wall
        // since the sdiv here should always be on only one axis, we can just use magnitude
        min_x := axis_x && abs(nsdiv.x) < LEVEL_COLLISION_CORRECT_MIN_SUBDIV
        min_y := !axis_x && abs(nsdiv.y) < LEVEL_COLLISION_CORRECT_MIN_SUBDIV
        if min_x || min_y {
            continue_iter = false
        }
        return ppos, nsdiv, continue_iter, true
    } else {
        // if weve moved farther than originally wanted, just do the original movement
        overshot_x := axis_x && abs(opos.x - ppos.x) >= abs(opos.x - npos.x)
        overshot_y := !axis_x && abs(opos.y - ppos.y) >= abs(opos.y - npos.y)

        if overshot_x {
            tppos.x = npos.x
            continue_iter = false
        } else if overshot_y {
            tppos.y = npos.y
            continue_iter = false
        }
        
        return tppos, sdiv, continue_iter, false
    }
}

LEVEL_increment_circle_collision_correction :: proc(
    cir: Circle, new_position: FVector, level: ^Level
) -> (final_pos: FVector, collided_x, collided_y: bool) {
    final_pos = new_position
    collided_x = false
    collided_y = false

    cir := cir
    orig_pos := get_circle_pos(cir)
    move_vec := vector_sub(new_position, orig_pos)

    subdivision := move_vec / 2
    sdx_sign: f32 = 1
    if subdivision.x < 0 { sdx_sign = -1 }
    sdy_sign: f32 = 1
    if subdivision.y < 0 { sdy_sign = -1 }

    if abs(subdivision.x) >= LEVEL_TILE_SIZE { subdivision.x = sdx_sign * (LEVEL_TILE_SIZE - 1) }
    if abs(subdivision.y) >= LEVEL_TILE_SIZE { subdivision.y = sdx_sign * (LEVEL_TILE_SIZE - 1) }

    iterating_x, iterating_y: bool
    iterating_x = subdivision.x != 0
    iterating_y = subdivision.y != 0

    prospect_position := orig_pos
    for iterating_x || iterating_y {
        if iterating_x {
            continue_iter, collided: bool
            test_subdiv := FVector{ subdivision.x, 0 }

            prospect_position, test_subdiv, continue_iter, collided = LEVEL_iterate_axis(
                prospect_position, orig_pos, new_position, test_subdiv, cir.r, level
            )

            subdivision.x = test_subdiv.x

            iterating_x = continue_iter
            collided_x |= collided
        }
        if iterating_y {
            continue_iter, collided: bool
            test_subdiv := FVector{ 0, subdivision.y }

            prospect_position, test_subdiv, continue_iter, collided = LEVEL_iterate_axis(
                prospect_position, orig_pos, new_position, test_subdiv, cir.r, level
            )

            subdivision.y = test_subdiv.y

            iterating_y = continue_iter
            collided_y |= collided
        }
    }

    final_pos = prospect_position

    return final_pos, collided_x, collided_y
}
