package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import math "core:math"
import rand "core:math/rand"

AI_follower_component :: struct {

}

AI_create_follower :: proc(for_id, track_id: int, spos: FVector) -> AI_Wrapper {
    return {
        type = AI_follower_component{
        },
        ai_proc = AI_follower_proc,   
        ai_for_sid = for_id,
        tracked_sid = track_id,
    }
}

AI_follower_proc :: proc(ai: ^AI_Wrapper, game: ^Game) -> (delete: bool) {
    ai_follower := &ai.type.(AI_follower_component)

    tracker, tracker_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !tracker_ok { return true }

    tracker.move_dir = vector_normalize(tracked.position - tracker.position)
    SHIP_face_position(tracker, tracked.position)

    return false
}