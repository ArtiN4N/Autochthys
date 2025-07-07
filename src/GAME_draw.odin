package src

import rl "vendor:raylib"

GAME_draw :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    GAME_draw_far_background(render_man, game)

    // we can draw tiles once and then never again
    // since each level of rendering is done on a different texture
    //GAME_draw_map_tiles(render_man, game)
    GAME_draw_near_background(render_man, game)
    GAME_draw_items(render_man, game)
    GAME_draw_entities(render_man, game)
    GAME_draw_foreground(render_man, game)
    GAME_draw_ui(render_man, game)
}

GAME_draw_far_background :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.far_background)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
}
GAME_draw_static_map_tiles :: proc(render_man: ^APP_Render_Manager, level_man: ^LEVEL_Manager, tag: LEVEL_Tag, force_draw_no_aggresion: bool = false) {
    rl.BeginTextureMode(render_man.map_tiles)
    defer rl.EndTextureMode()

    LEVEL_draw(&level_man.levels[tag], level_man, force_draw_no_aggresion)
}
GAME_draw_map_tiles :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.map_tiles)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
}
GAME_draw_near_background :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.near_background)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
}
GAME_draw_items :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.items)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    for e in game.level_manager.exp_points {
        STATS_draw_exp(e)
    }
}

GAME_simplified_draw_entities :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    SHIP_draw_player(game.player)
    GAME_draw_cursor(game.cursor_position)
}

GAME_draw_entities :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.entities)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
    // right now, we only use one dynamic array for level entities like ships and bullets
    // meaning that the next levels entities are drawn in the previous level as a transition is occuring
    // this looks really confusing
    // to stop this, when the app is in transition it calls a simplified entity draw proc
    // which just wont draw and variable entities like that
    // to fix it, the easiest way i think would be to adjust the app renderer to funnel all the multiple render textures
    // into one render texture
    // that way, on transition, we could save a copy of the previous levels render texture
    // and draw that for the transition, instead of directly using a draw call after updating the current level texture to the
    // previous levels mid loop
    app_state := APP_global_app.state
    if tstate, ok := app_state.(APP_Transition_State); ok && tstate.to == .Game && tstate.from == .Game {
        GAME_simplified_draw_entities(render_man, game)
        return
    }

    for &s in &game.level_manager.enemies {
        SHIP_draw(s)
    }

    SHIP_draw_player(game.player)

    for &b in &game.level_manager.ally_bullets {
        SHIP_draw_bullet(&b, true)
    }
    for &b in &game.level_manager.enemy_bullets {
        SHIP_draw_bullet(&b)
    }

    for &h in &game.level_manager.hit_markers {
        STATS_draw_hitmarker(&h)
    }
}
GAME_draw_foreground :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.foreground)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    //avoid drawing cursor twice in inventory
    // this is a hack and it sucks but...
    app_state := APP_global_app.state
    if tstate, ok := app_state.(APP_Transition_State); ok && tstate.to == .Inventory{
        return
    }

    GAME_draw_cursor(game.cursor_position)
}
GAME_draw_ui :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.ui)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    GAME_draw_player_hud(&game.player, game.player_stats)
}