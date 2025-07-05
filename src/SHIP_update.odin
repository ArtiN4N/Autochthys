package src

import rl "vendor:raylib"
import math "core:math"

SHIP_update :: proc(s: ^Ship, blist: ^[dynamic]SHIP_Bullet, level: ^Level) {
    SHIP_update_invincibility(s)

    new_pos := s.position + (s.move_dir * s.speed + s.velocity) * dt
    LEVEL_move_with_collision(&s.position, new_pos, s.collision_radius, level)

    SHIP_update_gun(&s.gun, s.position, s.rotation, blist)
}

SHIP_update_invincibility :: proc(s: ^Ship) {
    if s.invincibility_active {
        if s.invincibility_elapsed >= s.invincibility_time {
            s.invincibility_elapsed = 0
            s.invincibility_active = false
        } else { s.invincibility_elapsed += dt }
    }

    if s.damaged_active {
        if s.damaged_elapsed >= s.damaged_time {
            s.damaged_elapsed = 0
            s.damaged_active = false
        } else { s.damaged_elapsed += dt }
    }
}