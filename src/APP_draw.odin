package src

import rl "vendor:raylib"
import fmt "core:fmt"

APP_draw_debug :: proc(app: ^App) {
    rl.BeginTextureMode(app.render_manager.debug)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    player := app.game.player
    font := APP_get_global_default_font()

    rl.DrawTextEx(font^, rl.TextFormat("fps=%d", rl.GetFPS()), {5, 5}, 20, 2, WHITE_COLOR)

    total_bullets := len(app.game.ally_bullets) + len(app.game.enemy_bullets)
    rl.DrawTextEx(font^, rl.TextFormat("bullets=%d", total_bullets), {5, 25}, 20, 2, WHITE_COLOR)

    total_ships := len(app.game.enemies) + 1
    rl.DrawTextEx(font^, rl.TextFormat("ships=%d", total_ships), {5, 45}, 20, 2, WHITE_COLOR)

    total_ai := len(app.game.ai_collection)
    rl.DrawTextEx(font^, rl.TextFormat("ai=%d", total_ai), {5, 65}, 20, 2, WHITE_COLOR)

    total_xp := len(app.game.exp_points)
    rl.DrawTextEx(font^, rl.TextFormat("xp=%d", total_xp), {5, 85}, 20, 2, WHITE_COLOR)

    total_hm := len(app.game.hit_markers)
    rl.DrawTextEx(font^, rl.TextFormat("hm=%d", total_hm), {5, 105}, 20, 2, WHITE_COLOR)
}

APP_draw :: proc(app: ^App) {
    rl.ClearBackground(WHITE_COLOR)

    switch t in app.state {
    case APP_Game_State:
        GAME_draw(&app.render_manager, &app.game)
    case APP_Menu_State:
        MENU_draw(&app.render_manager, app.curr_menu)
    case APP_Transition_State:
        TRANSITION_draw(&app.render_manager, app, t)
    case nil:
    }

    when ODIN_DEBUG { APP_draw_debug(app) }
}