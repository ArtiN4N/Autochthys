package src

import rl "vendor:raylib"
import log "core:log"

Game :: struct {
    player: Ship,
    player_stats: STATS_Player,

    cursor_position: FVector,

    ai_collection: AI_Collection,

    level_manager: LEVEL_Manager,
}

TEMP_SPAWN_POS_1 :: FVector{64, 64}
TEMP_SPAWN_POS_2 :: FVector{68, 440}
TEMP_SPAWN_POS_3 :: FVector{448, 64}
TEMP_SPAWN_POS_4 :: FVector{448, 448}

GAME_load_game_A :: proc(game: ^Game) {
    game.ai_collection = make(AI_Collection)

    game.player = SHIP_create_ship(.Player, {0, 0})
    pid := game.player.sid

    LEVEL_load_manager_A(&game.level_manager)
    LEVEL_manager_set_level(&game.level_manager, game, LEVEL_DEFAULT)

    rw, rh := APP_get_global_render_size()
    game.cursor_position = { f32(rw) / 2, f32(rh) / 2 }

    log.infof("Game data loaded")
}

GAME_destroy_game_D :: proc(game: ^Game) {
    delete(game.ai_collection)
    LEVEL_destroy_manager_D(&game.level_manager)

    log.infof("Game data destroyed")
}

GAME_add_ai :: proc(game: ^Game, ai: AI_Wrapper) {
    append(&game.ai_collection, ai)
}

// should make tabling more efficient
// maybe have a map from sid to index?
GAME_table_ship_with_id :: proc(game: ^Game, sid: int) -> (s: ^Ship, ok: bool) {
    if sid == game.player.sid { return &game.player, true }
    for &s in &game.level_manager.enemies {
        if sid == s.sid { return &s, true }
    }
    return nil, false
}