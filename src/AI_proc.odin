package src

import fmt "core:fmt"
import rand "core:math/rand"
import math "core:math"
import rl "vendor:raylib"

AI_proc_signature :: proc(ai: ^AI_Wrapper, game: ^Game) -> (delete: bool)

AI_add_component_to_game :: proc(game: ^Game, pos: IVector, tracking_id: int, stype: CONST_Ship_Type, aggr: int) {
    pos := LEVEL_convert_coords_to_real_position(pos)
    eid := LEVEL_add_enemy(
        man = &game.level_manager,
        e = SHIP_create_ship(stype, pos, ANIMATION_Entity_Type.Minnow, aggr)
    )

    ai: AI_Wrapper
    switch stype {
    case .Lobber:
        ai = AI_create_lobber(eid, tracking_id, pos)
    case .Tracker:
        ai = AI_create_tracker(eid, tracking_id, pos)
    case .Follower:
        ai = AI_create_follower(eid, tracking_id, pos)
    case .Player:
    case .Octopus:
        ai = AI_create_octopus(eid, tracking_id, pos)
    }

    ai.delay = 0.5 + rand.float32(rng) * 0.5 // Random delay from 0.5 -> 1
    ai.seen = false
    ai.patrol_timer = 0.5

    GAME_add_ai(game, ai)
}

AI_see_tracked :: proc(ai: ^AI_Wrapper, game: ^Game) -> bool {
    tracker, tracker_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)
    if !tracker_ok || !tracked_ok { return false }

    level := &game.level_manager.levels[game.level_manager.current_level]

    line := Line{ a = tracker.position, b = tracked.position }

    // If line collides with collision tiles, can't see
    if LEVEL_check_line_collides(line, level) {
        return false
    }

    return true
}

AI_rotate_to_tracked :: proc(ai: ^AI_Wrapper, game: ^Game) {   
    tracker, tracker_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)

    if !tracked_ok || !tracker_ok { return }

    tracker.move_dir = vector_normalize(tracked.position - tracker.position)
    SHIP_face_position(tracker, tracked.position)
}

AI_patrol :: proc(ai: ^AI_Wrapper, game: ^Game) {
    enemy, ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    if !ok {
        return
    }

    ai.patrol_timer -= dt

    if ai.patrol_timer <= 0 {
        ai.patrol_timer = rand.float32(rng) * 2.0 + 1.0

        radius: f32 = LEVEL_TILE_SIZE * 3
        angle := rand.float32(rng) * 2.0 * math.PI

        offset := rl.Vector2{
            radius * math.cos(angle),
            radius * math.sin(angle),
        }

        target_pos := enemy.position + offset 
        ai.patrol_dir = vector_normalize(offset) //Store patrol direction for rotation on upcoming frames
    }

    if vector_magnitude(ai.patrol_dir) > 0.01 {
        desired_angle := math.atan2(ai.patrol_dir.y, ai.patrol_dir.x)
        current_angle := enemy.rotation 

        turn_speed := f32(2.0 * math.PI)
        max_step := turn_speed * dt

        diff := math.remainder(desired_angle - current_angle, 2.0 * math.PI)

        if math.abs(diff) <= max_step {
            enemy.rotation = desired_angle
        } else if diff > 0 {
            enemy.rotation += max_step
        } else {
            enemy.rotation -= max_step
        }

        enemy.rotation = math.remainder(enemy.rotation, 2.0 * math.PI) //Keep rotation between 2pi
    }
}
