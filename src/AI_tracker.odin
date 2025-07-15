package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import math "core:math"
import rand "core:math/rand"

AI_tracker_state :: enum {
    Idle,
    BackingUp,
    Charging,
    Cooldown,
}

AI_tracker_component :: struct {
    tracked_pos: FVector,

    state: AI_tracker_state,
    state_timer: f32,
}

AI_create_tracker :: proc(for_id, track_id: int, spos: FVector) -> AI_Wrapper {
    return {
        type = AI_tracker_component{
            tracked_pos = spos,

            state = .Idle,
            state_timer = rand.float32_range(0.5, 2.0), // random initial idle duration
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

    ai_tracker.state_timer -= dt

    diff := ai_tracker.tracked_pos - tracker.position
    dist := vector_magnitude(diff)
    dir := FVECTOR_ZERO
    if dist > 0.001 {
        dir = vector_normalize(diff)
    }

    stats := &CONST_ship_stats[tracker.stat_type]

    switch ai_tracker.state {
    case .Idle:
        SHIP_face_position(tracker, tracked.position)
        tracker.move_dir = FVECTOR_ZERO

        if ai_tracker.state_timer <= 0 {
            ai_tracker.tracked_pos = tracked.position
            ai_tracker.state = .BackingUp
            ai_tracker.state_timer = 0.4
        }

    case .BackingUp:
        SHIP_face_position(tracker, ai_tracker.tracked_pos)

        if ai_tracker.state_timer <= 0 {
            ai_tracker.state = .Charging
        } else {
            backing_speed := f32(20.0)
            step := dir * backing_speed * dt
            wanted_pos := tracker.position - step
            LEVEL_global_move_with_collision(&tracker.position, wanted_pos, stats.collision_radius)
            tracker.move_dir = FVECTOR_ZERO
        }

    case .Charging:
        SHIP_face_position(tracker, ai_tracker.tracked_pos)

        if dist < AI_TRACKER_MIN_DIST {
            tracker.move_dir = FVECTOR_ZERO
            ai_tracker.state = .Cooldown
            ai_tracker.state_timer = 1.0
        } else {
            tracker.move_dir = dir
        }

    case .Cooldown:
        SHIP_face_position(tracker, tracked.position)
        tracker.move_dir = FVECTOR_ZERO

        if ai_tracker.state_timer <= 0 {
            ai_tracker.state = .Idle
            ai_tracker.state_timer = rand.float32_range(0.5, 2.0) 
        }
    }

    return false
}
