package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import math "core:math"
import rand "core:math/rand"

AI_lobber_component :: struct {
    ai_for_sid: int,
    tracked_sid: int,

    desired_dist: f32, 
    desired_pos: FVector,

    aim_time: f32,
    aim_elapsed: f32,

    just_shot: bool,
}

AI_create_lobber :: proc(for_id, track_id: int, spos: FVector) -> AI_Component {
    return {
        type = AI_lobber_component{
            ai_for_sid = for_id,
            tracked_sid = track_id,

            desired_dist = AI_LOBBER_DEFAULT_DESIRED_DIST,
            desired_pos = spos,
            
            aim_time = AI_LOBBER_DEFAULT_AIM_TIME,
            aim_elapsed = 0,

            just_shot = false,
        },
        ai_proc = AI_lobber_proc,   
    }
}

AI_add_lobber_to_game :: proc(game: ^Game, pos: FVector, tracking_id: int) {
    eid := LEVEL_add_enemy(
        man = &game.level_manager,
        e = SHIP_create_ship(.Lobber, pos)
    )
    GAME_add_ai(
        game,
        AI_create_lobber(
            eid, tracking_id, pos
        )
    )
}


AI_lobber_proc :: proc(ai: ^AI_Component, game: ^Game) -> (delete: bool) {
    ai := &ai.type.(AI_lobber_component)
    rw, rh := APP_get_global_render_size()
    
    lobber, lobber_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !lobber_ok { return true }
    l_stats := &CONST_ship_stats[lobber.stat_type]

    dist_from_tracked := vector_magnitude(lobber.position - tracked.position)
    dist_from_desired := vector_magnitude(lobber.position - ai.desired_pos)

    lobber.gun.shooting = false
    if dist_from_desired < AI_LOBBER_MIN_DIST {
        ai.desired_pos = lobber.position
    }

    ready_to_shoot := lobber.position == ai.desired_pos && !lobber.gun.reloading_active && ai.aim_elapsed >= ai.aim_time
    aiming := lobber.position == ai.desired_pos && (lobber.gun.reloading_active || ai.aim_elapsed < ai.aim_time)

    if aiming {
        lobber.move_dir = FVECTOR_ZERO

        aim_dir := vector_normalize(tracked.position - lobber.position)
        desired_rot := math.atan2(-aim_dir.y, aim_dir.x)
        lobber.rotation = desired_rot

        ai.aim_elapsed += dt
    } else if ready_to_shoot {
        lobber.move_dir = FVECTOR_ZERO

        lobber.gun.shooting = true

        ai.aim_elapsed = 0
        
        if dist_from_tracked < ai.desired_dist {
            move_dir := vector_normalize(lobber.position - tracked.position)
            wanted_pos := lobber.position + move_dir * ai.desired_dist

            // collision check desired position
            ai.desired_pos = lobber.position
            LEVEL_move_with_collision(&ai.desired_pos, wanted_pos, l_stats.collision_radius, game.level_manager.current_level)
        }
    } else {
        lobber.move_dir = vector_normalize(ai.desired_pos - lobber.position)
    }
    return false
}