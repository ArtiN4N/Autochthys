package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import math "core:math"
import rand "core:math/rand"

AI_octopus_component :: struct {
    just_shot: bool,
}

AI_create_octopus :: proc(for_id, track_id: int, spos: FVector) -> AI_Wrapper {
    return {
        type = AI_octopus_component{
            just_shot = false,
        },
        ai_proc = AI_octopus_proc,   
        ai_for_sid = for_id,
        tracked_sid = track_id,
    }
}

AI_octopus_proc :: proc(ai: ^AI_Wrapper, game: ^Game) -> (delete: bool) {
    ai_octopus := &ai.type.(AI_octopus_component)
    rw, rh := APP_get_global_render_size()
    
    octopus, octopus_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !octopus_ok { return true }

    aim_dir := vector_normalize(tracked.position - octopus.position)
    desired_rot := math.atan2(-aim_dir.y, aim_dir.x)
    octopus.rotation = desired_rot

    l_stats := &CONST_ship_stats[octopus.stat_type]

    if octopus.gun.shooting == false {octopus.gun.shooting = true}
    return false
}