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

AI_create_lobber :: proc(for_id, track_id: int, ddist, atime: f32, spos: FVector) -> AI_Component {
    return {
        type = AI_lobber_component{
            ai_for_sid = for_id,
            tracked_sid = track_id,

            desired_dist = ddist,
            desired_pos = spos,
            
            aim_time = atime,
            aim_elapsed = 0,

            just_shot = false,
        },
        ai_proc = AI_lobber_proc,   
    }
}

AI_add_lobber_to_game :: proc(game: ^Game, pos: FVector, tracking_id: int) {
    eid := GAME_add_enemy(
        game = game,
        e = SHIP_create_ship(CONST_Ship_Defaults[.Lobber], pos)
    )
    GAME_add_ai(
        game,
        AI_create_lobber(
            eid, tracking_id, AI_LOBBER_DEFAULT_DESIRED_DIST, AI_LOBBER_DEFAULT_AIM_TIME, pos
        )
    )
}


AI_lobber_proc :: proc(ai: ^AI_Component, game: ^Game) -> (delete: bool) {
    ai := &ai.type.(AI_lobber_component)
    rw, rh := APP_get_global_render_size()

    lobber, lobber_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !lobber_ok { return true }

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
            ai.desired_pos = lobber.position + move_dir * ai.desired_dist

            fmt.printfln("desired = %v", ai.desired_pos)

            if ai.desired_pos.x < 0 { ai.desired_pos.x = 0 }
            if ai.desired_pos.x > f32(rw) { ai.desired_pos.x = f32(rw) }

            if ai.desired_pos.y < 0 { ai.desired_pos.y = 0 }
            if ai.desired_pos.y > f32(rh) { ai.desired_pos.y = f32(rh) }
        }
    } else {
        lobber.move_dir = vector_normalize(ai.desired_pos - lobber.position)
    }
    return false
}