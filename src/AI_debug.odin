package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import math "core:math"
import rand "core:math/rand"

AI_debug_component :: struct {
    ai_for_sid: int,
    tracked_sid: int,

    just_shot: bool,
}

AI_create_debug :: proc(for_id, track_id: int, spos: FVector) -> AI_Wrapper {
    return {
        type = AI_debug_component{
            ai_for_sid = for_id,
            tracked_sid = track_id,

            just_shot = false,
        },
        ai_proc = AI_debug_proc,   
    }
}

AI_debug_proc :: proc(ai: ^AI_Wrapper, game: ^Game) -> (delete: bool) {
    ai := &ai.type.(AI_debug_component)
    rw, rh := APP_get_global_render_size()
    
    debug, debug_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !debug_ok { return true }

    aim_dir := vector_normalize(tracked.position - debug.position)
    desired_rot := math.atan2(-aim_dir.y, aim_dir.x)
    debug.rotation = desired_rot

    l_stats := &CONST_ship_stats[debug.stat_type]

    if debug.gun.shooting == false {debug.gun.shooting = true}
    return false
}