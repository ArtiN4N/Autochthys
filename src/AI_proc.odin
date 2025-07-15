package src

import fmt "core:fmt"
import rand "core:math/rand"
import math "core:math"

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

    GAME_add_ai(game, ai)
}

AI_see_tracked :: proc(ai: ^AI_Wrapper, game: ^Game) -> bool {
    tracker, tracker_ok := GAME_table_ship_with_id(game, ai.ai_for_sid)
    tracked, tracked_ok := GAME_table_ship_with_id(game, ai.tracked_sid)
    level := game.level_manager.levels[game.level_manager.current_level]

    if(!tracker_ok || !tracked_ok) { return false }

    start := tracker.position
    end := tracked.position
    
    tile_size := LEVEL_TILE_SIZE

    x0 := int(start.x) / tile_size
    y0 := int(start.y) / tile_size
    x1 := int(end.x) / tile_size
    y1 := int(end.y) / tile_size

    dx := abs(x1 - x0)
    dy := abs(y1 - y0)

    sx: int
    if x0 < x1 {
        sx = 1
    } else {
        sx = -1
    }

    sy: int
    if y0 < y1 {
        sy = 1
    } else {
        sy = -1
    }

    err := dx - dy
    x := x0
    y := y0

    for {
        if x < 0 || x >= LEVEL_WIDTH || y < 0 || y >= LEVEL_HEIGHT {
            break  
        }
if LEVEL_index_collision(&level, x, y) {
    fmt.printfln("Checking tile (%d, %d): collision = true", x, y)
}        if LEVEL_index_collision(&level, x, y) {
            return false
        }

        if x == x1 && y == y1 {
            break
        }

        e2 := 2 * err
        if e2 > -dy {
            err -= dy
            x += sx
        }
        if e2 < dx {
            err += dx
            y += sy
        }
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