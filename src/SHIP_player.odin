package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"

SHIP_face_position :: proc(s: ^Ship, pos: FVector) {
    old_rot := s.rotation

    ship_pos_vec := pos - s.position
    ship_pos_angle_vec := vector_normalize(ship_pos_vec)

    theta := math.atan2(-ship_pos_angle_vec.y, ship_pos_angle_vec.x)
    s.rotation = theta

    // parts rotation
    if old_rot == s.rotation do return
}

SHIP_player_update_parry :: proc(s: ^Ship) {
    stats_man := &APP_global_app.game.stats_manager

    if stats_man.parry_state == .Ready {
        stats_man.parry_elapsed = 0
        stats_man.parry_cooldown_elapsed = 0
    }

    if stats_man.parry_state == .Active || stats_man.parry_state == .Carry {
        stats_man.parry_cooldown_elapsed = 0
        if stats_man.parry_elapsed >= STATS_PARRY_TIME do stats_man.parry_state = .Cooldown
        else do stats_man.parry_elapsed += dt
    }

    if stats_man.parry_state == .Cooldown {
        stats_man.parry_elapsed = 0
        if stats_man.parry_cooldown_elapsed >= STATS_PARRY_COOLDOWN do stats_man.parry_state = .Ready
        stats_man.parry_cooldown_elapsed += dt
    }

    if !rl.IsMouseButtonPressed(.RIGHT) do return

    if stats_man.parry_state == .Ready || stats_man.parry_state == .Carry {
        //good parry sfx
        stats_man.parry_state = .Active
        SOUND_global_fx_manager_play_tag(.Good_Parry_Swing)
    } else if stats_man.parry_state == .Active || stats_man.parry_state == .Cooldown {
        //bad parry sfx
        stats_man.parry_state = .Cooldown
        SOUND_global_fx_manager_play_tag(.Bad_Parry_Swing)
        stats_man.parry_cooldown_elapsed = 0
    }
}

SHIP_update_player :: proc(s: ^Ship, cursor_pos: FVector, blist: ^[dynamic]Bullet) {
    stats := &CONST_ship_stats[s.stat_type]

    // by finding the vector between the ship and the cursor,
    // we can normalize it and use inverse trig functions to find the angle
    SHIP_face_position(s, cursor_pos)

    move_dir := FVECTOR_ZERO
    if rl.IsKeyDown(.D) { move_dir.x += 1 }
    if rl.IsKeyDown(.A) { move_dir.x -= 1 }

    if rl.IsKeyDown(.S) { move_dir.y += 1 }
    if rl.IsKeyDown(.W) { move_dir.y -= 1 }

    SHIP_player_update_parry(s)
    //if rl.IsMouseButtonDown(.RIGHT) { SHIP_try_parry(s) } //parry

    s.move_dir = vector_normalize(move_dir)

    s.gun.shooting = rl.IsMouseButtonDown(.LEFT)

    if rl.IsKeyPressed(.R) && s.gun.ammo < s.gun.max_ammo {
        s.gun.ammo = 0
        s.gun.reloading_active = true
        SOUND_global_fx_manager_play_tag(.Reload)
    }

    SHIP_update(s, blist, true)

    //check warps
    expanded_cir := Circle{s.position.x, s.position.y, stats.collision_radius + 0.5}
    for dir in LEVEL_Room_Connection {
        warp_rect := LEVEL_get_hazard_rect(dir)
        if circle_collides_rect(expanded_cir, warp_rect) {
            LEVEL_global_world_warp_to(dir)
            break
        }
    }
}

SHIP_draw_player :: proc(s: ^Ship) {
    SHIP_draw(s, true)
}