package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import math "core:math"
import rand "core:math/rand"

AI_tracker_component :: struct {
    ai_for_sid: int,
    tracked_sid: int,

    tracker_refresh: f32,
    tracker_elapsed: f32,
 
    tracked_pos: FVector,
}

AI_create_tracker :: proc(for_id, track_id: int, refresh: f32, spos: FVector) -> AI_Component {
    return {
        type = AI_tracker_component{
            ai_for_sid = for_id,
            tracked_sid = track_id,

            tracker_refresh = refresh,
            // we dont want trackers moving like telepathic ants
            // so we randomize their elapsed time to offset them
            tracker_elapsed = rand.float32() * refresh,
            
            tracked_pos = spos,
        },
        ai_proc = AI_tracker_proc,   
    }
}

AI_add_tracker_to_game :: proc(game: ^Game, pos: FVector, tracking_id: int) {
    eid := GAME_add_enemy(
        game = game,
        e = SHIP_create_ship(CONST_Ship_Defaults[.Tracker], pos)
    )
    GAME_add_ai(
        game,
        AI_create_tracker(
            eid, tracking_id, AI_TRACKER_DEFAULT_REFRESH, pos
        )
    )
}


AI_tracker_proc :: proc(ai: ^AI_Component, game: ^Game) -> (delete: bool) {
    ai := &ai.type.(AI_tracker_component)

    tracker, tracker_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !tracker_ok { return true }

    if ai.tracker_elapsed >= ai.tracker_refresh {
        ai.tracked_pos = tracked.position
        ai.tracker_elapsed = 0
    }
    ai.tracker_elapsed += dt

    new_move_dir := vector_normalize(ai.tracked_pos - tracker.position)
    if vector_dist(ai.tracked_pos, tracker.position) < AI_TRACKER_MIN_DIST {
        new_move_dir = FVECTOR_ZERO
    }

    if new_move_dir != FVECTOR_ZERO { SHIP_face_position(tracker, ai.tracked_pos) }

    tracker.move_dir = new_move_dir

    return false
}