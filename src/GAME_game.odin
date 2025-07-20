package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"

Game :: struct {
    in_game: bool,
    player: Ship,
    player_stats: STATS_Player,

    cursor_position: FVector,

    ai_collection: AI_Collection,
    animation_collections: ANIMATION_Master_Collections,

    level_manager: LEVEL_Manager,
    interaction_manager: INTERACTION_Manager,
    current_world: LEVEL_World,
    stats_manager: STATS_Manager,
    item_manager: ITEM_Manager,
    inventory_manager: INVENTORY_Manager,
    miniboss_manager: MINIBOSS_Manager,
}

TEMP_SPAWN_POS_1 :: FVector{64, 64}
TEMP_SPAWN_POS_2 :: FVector{68, 440}
TEMP_SPAWN_POS_3 :: FVector{448, 64}
TEMP_SPAWN_POS_4 :: FVector{448, 448}

GAME_load_game_A :: proc(game: ^Game) {
    ANIMATION_add_collections_from_master_list(&game.animation_collections)

    STATS_create_manager(&game.stats_manager)
    ITEM_create_manager(&game.item_manager)
    INVENTORY_create_manager(&game.inventory_manager)
    
    game.ai_collection = make(AI_Collection)

    game.player = SHIP_create_ship(CONST_Ship_Type.Player, {0, 0}, ANIMATION_Entity_Type.Koi)
    pid := game.player.sid

    LEVEL_load_manager_A(&game.level_manager)

    rw, rh := APP_get_global_render_size() 
    game.cursor_position = { f32(rw) / 2, f32(rh) / 2 }

    LEVEL_create_world_A(&game.current_world)
    
    INTERACTION_create_manager_A(&game.interaction_manager)

    MINIBOSS_Set_State(&game.miniboss_manager, .None)

    MENU_init_water_sim(&APP_global_app.menu)

    log.infof("Game data loaded")
}

GAME_destroy_game_D :: proc(game: ^Game) {
    delete(game.ai_collection)
    ANIMATION_wipe_collections_from_master_list(&game.animation_collections)

    LEVEL_destroy_manager_D(&game.level_manager)
    LEVEL_destroy_world_D(&game.current_world)

    INTERACTION_destroy_manager_D(&game.interaction_manager)

    MINIBOSS_destroy_manager_D(&game.miniboss_manager)

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

GAME_global_player_die :: proc() {
    log.infof("Player died. Starting outro")
    OUTRO_global_event()
}