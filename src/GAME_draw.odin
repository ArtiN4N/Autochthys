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
GAME_draw_static_map_tiles :: proc(render_man: ^APP_Render_Manager, level_man: ^LEVEL_Manager) {
    rl.BeginTextureMode(render_man.map_tiles)
    defer rl.EndTextureMode()

    LEVEL_draw(level_man.current_level)
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

    for e in game.exp_points {
        STATS_draw_exp(e)
    }
}
GAME_draw_entities :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.entities)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    for &s in &game.enemies {
        SHIP_draw(s)
    }

    SHIP_draw_player(game.player)

    for &b in &game.ally_bullets {
        SHIP_draw_bullet(&b, true)
    }
    for &b in &game.enemy_bullets {
        SHIP_draw_bullet(&b)
    }

    for &h in &game.hit_markers {
        STATS_draw_hitmarker(&h)
    }

    GAME_draw_cursor(game.cursor_position)
}
GAME_draw_foreground :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.foreground)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
}
GAME_draw_ui :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.ui)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    GAME_draw_player_hud(&game.player, game.player_stats)
}