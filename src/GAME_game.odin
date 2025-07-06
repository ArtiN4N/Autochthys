package src

import rl "vendor:raylib"
import log "core:log"

Game :: struct {
    player: Ship,
    player_stats: STATS_Player,
    enemies: [dynamic]Ship,

    cursor_position: FVector,

    enemy_bullets: [dynamic]SHIP_Bullet,
    ally_bullets: [dynamic]SHIP_Bullet,

    ai_collection: AI_Collection,

    exp_points: [dynamic]STATS_Experience,
    hit_markers: [dynamic]STATS_Hitmarker,

    level_manager: LEVEL_Manager,
}

TEMP_SPAWN_POS_1 :: FVector{64, 64}
TEMP_SPAWN_POS_2 :: FVector{64, 448}
TEMP_SPAWN_POS_3 :: FVector{448, 64}
TEMP_SPAWN_POS_4 :: FVector{448, 448}

GAME_load_game_A :: proc(game: ^Game) {
    LEVEL_load_manager(&game.level_manager)
    LEVEL_manager_set_level(&game.level_manager, LEVEL_DEFAULT)

    game.player = SHIP_create_ship(CONST_Ship_Defaults[.Player], {0, 0})
    pid := game.player.sid
    SHIP_warp(&game.player, {100, 100})

    rw, rh := APP_get_global_render_size()
    game.cursor_position = { f32(rw) / 2, f32(rh) / 2 }

    game.enemy_bullets = make([dynamic]SHIP_Bullet)
    game.ally_bullets = make([dynamic]SHIP_Bullet)
    game.enemies = make([dynamic]Ship)
    game.ai_collection = make(AI_Collection)
    game.exp_points = make([dynamic]STATS_Experience)
    game.hit_markers = make([dynamic]STATS_Hitmarker)

    AI_add_tracker_to_game(game, TEMP_SPAWN_POS_1, pid)
    AI_add_tracker_to_game(game, TEMP_SPAWN_POS_2, pid)
    AI_add_octopus_to_game(game, TEMP_SPAWN_POS_3, pid)
    AI_add_lobber_to_game(game, TEMP_SPAWN_POS_4, pid)

    log.infof("Game data loaded")
}

GAME_destroy_game_D :: proc(game: ^Game) {
    delete(game.enemy_bullets)
    delete(game.ally_bullets)
    delete(game.enemies)
    delete(game.ai_collection)
    delete(game.exp_points)
    delete(game.hit_markers)

    log.infof("Game data destroyed")
}

GAME_add_enemy :: proc(game: ^Game, e: Ship) -> (eid: int) {
    append(&game.enemies, e)
    return e.sid
}

GAME_add_ai :: proc(game: ^Game, ai: AI_Component) {
    append(&game.ai_collection, ai)
}

GAME_add_exp :: proc(game: ^Game, e: STATS_Experience) {
    append(&game.exp_points, e)
}

// should make tabling more efficient
// maybe have a map from sid to index?
GAME_table_ship_with_id :: proc(game: ^Game, sid: int) -> (s: ^Ship, ok: bool) {
    if sid == game.player.sid { return &game.player, true }
    for &s in &game.enemies {
        if sid == s.sid { return &s, true }
    }
    return nil, false
}