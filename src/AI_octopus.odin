package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import math "core:math"
import rand "core:math/rand"

AI_octopus_component :: struct {
    ai_for_sid: int,
    tracked_sid: int,

    desired_dist: f32, 
    desired_pos: FVector,

    aim_time: f32,
    aim_elapsed: f32,

    just_shot: bool,
}

AI_create_octopus :: proc(for_id, track_id: int, ddist, atime: f32, spos: FVector) -> AI_Component {
    return {
        type = AI_octopus_component{
            ai_for_sid = for_id,
            tracked_sid = track_id,

            desired_dist = ddist,
            desired_pos = spos,
            
            aim_time = atime,
            aim_elapsed = 0,

            just_shot = false,
        },
        ai_proc = AI_octopus_proc,   
    }
}

AI_add_octopus_to_game :: proc(game: ^Game, pos: FVector, tracking_id: int) {
    eid := GAME_add_enemy(
        game = game,
        e = SHIP_create_ship(CONST_Ship_Defaults[.Octopus], pos)
    )
    GAME_add_ai(
        game,
        AI_create_octopus(
            eid, tracking_id, AI_LOBBER_DEFAULT_DESIRED_DIST, AI_LOBBER_DEFAULT_AIM_TIME, pos
        )
    )
}


AI_octopus_proc :: proc(ai: ^AI_Component, game: ^Game) -> (delete: bool) {
    ai := &ai.type.(AI_octopus_component)
    rw, rh := APP_get_global_render_size()

    octopus, octopus_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !octopus_ok { return true }

    dist_from_tracked := vector_magnitude(octopus.position - tracked.position)
    dist_from_desired := vector_magnitude(octopus.position - ai.desired_pos)

    octopus.gun.shooting = false
    if dist_from_desired < AI_LOBBER_MIN_DIST {
        ai.desired_pos = octopus.position
    }

    ready_to_shoot := octopus.position == ai.desired_pos && !octopus.gun.reloading_active && ai.aim_elapsed >= ai.aim_time
    aiming := octopus.position == ai.desired_pos && (octopus.gun.reloading_active || ai.aim_elapsed < ai.aim_time)

    if aiming {
        octopus.move_dir = FVECTOR_ZERO

        aim_dir := vector_normalize(tracked.position - octopus.position)
        desired_rot := math.atan2(-aim_dir.y, aim_dir.x)
        octopus.rotation = desired_rot

        ai.aim_elapsed += dt
    } else if ready_to_shoot {
        octopus.move_dir = FVECTOR_ZERO

        octopus.gun.shooting = true

        ai.aim_elapsed = 0
        
        if dist_from_tracked < ai.desired_dist {
            move_dir := vector_normalize(octopus.position - tracked.position)
            wanted_pos := octopus.position + move_dir * ai.desired_dist

            // collision check desired position
            ai.desired_pos = octopus.position
            LEVEL_move_with_collision(&ai.desired_pos, wanted_pos, octopus.collision_radius, game.level_manager.current_level)
        }
    } else {
        octopus.move_dir = vector_normalize(ai.desired_pos - octopus.position)
    }
    return false
}