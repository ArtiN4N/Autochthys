package src

import rl "vendor:raylib"
import math "core:math"

SHIP_update :: proc(s: ^Ship, blist: ^[dynamic]Bullet) {
    stats := &CONST_ship_stats[s.stat_type]

    SHIP_update_invincibility(s)

    new_pos := s.position + (s.move_dir * stats.ship_speed + s.velocity) * dt
    LEVEL_global_move_with_collision(&s.position, new_pos, stats.collision_radius)

    GUN_update_gun(&s.gun, s.position, s.rotation, blist)

    ANIMATION_update_manager(&s.body_anim_manager)
    ANIMATION_manager_match_manager(&s.body_anim_manager, &s.tail_anim_manager)
    ANIMATION_manager_match_manager(&s.body_anim_manager, &s.fin_anim_manager)
}

SHIP_update_invincibility :: proc(s: ^Ship) {
    stats := &CONST_ship_stats[s.stat_type]

    if s.invincibility_active {
        if s.invincibility_elapsed >= stats.invincibility_time {
            s.invincibility_elapsed = 0
            s.invincibility_active = false
        } else { s.invincibility_elapsed += dt }
    }

    if s.damaged_active {
        if s.damaged_elapsed >= stats.damaged_time {
            s.damaged_elapsed = 0
            s.damaged_active = false
        } else { s.damaged_elapsed += dt }
    }
}