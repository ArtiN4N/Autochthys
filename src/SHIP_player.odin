package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"

SHIP_face_position :: proc(s: ^Ship, pos: FVector) {
    ship_pos_vec := pos - s.position
    ship_pos_angle_vec := vector_normalize(ship_pos_vec)

    theta := math.atan2(-ship_pos_angle_vec.y, ship_pos_angle_vec.x)
    s.rotation = theta
}

SHIP_update_player :: proc(s: ^Ship, cursor_pos: FVector, blist: ^[dynamic]SHIP_Bullet, level: ^Level) {
    stats := &CONST_ship_stats[s.stat_type]

    // by finding the vector between the ship and the cursor,
    // we can normalize it and use inverse trig functions to find the angle
    SHIP_face_position(s, cursor_pos)

    move_dir := FVECTOR_ZERO
    if rl.IsKeyDown(.D) { move_dir.x += 1 }
    if rl.IsKeyDown(.A) { move_dir.x -= 1 }

    if rl.IsKeyDown(.S) { move_dir.y += 1 }
    if rl.IsKeyDown(.W) { move_dir.y -= 1 }

    s.move_dir = vector_normalize(move_dir)

    s.gun.shooting = rl.IsMouseButtonDown(.LEFT)

    if rl.IsKeyPressed(.R) && s.gun.ammo < s.gun.max_ammo {
        s.gun.ammo = 0
        s.gun.reloading_active = true
    }

    SHIP_update(s, blist, level)

    //check warps
    expanded_cir := Circle{s.position.x, s.position.y, stats.collision_radius + 0.5}
    for coord, warp_id in level.warps_info.warp_tos {
        warp_tile := LEVEL_get_rect_from_coords(coord.x, coord.y)
        if circle_collides_rect(expanded_cir, warp_tile) {
            LEVEL_global_manager_set_level(warp_id, coord)
        }
    }
}

SHIP_draw_player :: proc(s: Ship) {
    SHIP_draw(s, true)
}