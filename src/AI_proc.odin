package src

import fmt "core:fmt"

AI_proc_signature :: proc(ai: ^AI_Wrapper, game: ^Game) -> (delete: bool)

AI_add_component_to_game :: proc(game: ^Game, pos: FVector, tracking_id: int, stype: CONST_Ship_Type) {
    eid := LEVEL_add_enemy(
        man = &game.level_manager,
        e = SHIP_create_ship(stype, pos)
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
    case .Debug:
        ai = AI_create_debug(eid, tracking_id, pos)
    }


    GAME_add_ai(game, ai)
}