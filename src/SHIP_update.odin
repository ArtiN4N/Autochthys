package src

import rl "vendor:raylib"
import math "core:math"

SHIP_update :: proc(s: ^Ship, blist: ^[dynamic]SHIP_Bullet) {
    SHIP_update_invincibility(s)

    s.position += (s.move_dir * s.speed + s.velocity) * dt

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