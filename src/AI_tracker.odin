package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import math "core:math"
import rand "core:math/rand"

AI_tracker_component :: struct {
    tracker_refresh: f32,
    tracker_elapsed: f32,
 
    tracked_pos: FVector,
}

AI_create_tracker :: proc(for_id, track_id: int, spos: FVector) -> AI_Wrapper {
    return {
        type = AI_tracker_component{
            tracker_refresh = AI_TRACKER_DEFAULT_REFRESH,
            // we dont want trackers moving like telepathic ants
            // so we randomize their elapsed time to offset them
            tracker_elapsed = rand.float32() * AI_TRACKER_DEFAULT_REFRESH * 0.5,
            
            tracked_pos = spos,
        },
        ai_proc = AI_tracker_proc,   
        ai_for_sid = for_id,
        tracked_sid = track_id,
    }
}

AI_tracker_proc :: proc(ai: ^AI_Wrapper, game: ^Game) -> (delete: bool) {
    ai_tracker := &ai.type.(AI_tracker_component)

    tracker, tracker_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !tracker_ok { return true }

    if ai_tracker.tracker_elapsed >= ai_tracker.tracker_refresh {
        ai_tracker.tracked_pos = tracked.position
        ai_tracker.tracker_elapsed = 0
    }
    ai_tracker.tracker_elapsed += dt

    new_move_dir := vector_normalize(ai_tracker.tracked_pos - tracker.position)
    if vector_dist(ai_tracker.tracked_pos, tracker.position) < AI_TRACKER_MIN_DIST {
        new_move_dir = FVECTOR_ZERO
    }

    if new_move_dir != FVECTOR_ZERO { SHIP_face_position(tracker, ai_tracker.tracked_pos) }

    tracker.move_dir = new_move_dir

    return false
}