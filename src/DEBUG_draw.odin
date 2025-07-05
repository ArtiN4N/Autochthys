package src

import rl "vendor:raylib"
import fmt "core:fmt"

DEBUG_draw :: proc(app: ^App) {
    
}

DEBUG_draw_console :: proc(app: ^App) {
    rl.BeginTextureMode(app.render_manager.debug)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    player := app.game.player
    font := APP_get_global_default_font()

    rl.DrawTextEx(font^, rl.TextFormat("fps=%d", rl.GetFPS()), {5, 5}, 20, 2, WHITE_COLOR)

    total_bullets := len(app.game.level_manager.ally_bullets) + len(app.game.level_manager.enemy_bullets)
    rl.DrawTextEx(font^, rl.TextFormat("bullets=%d", total_bullets), {5, 25}, 20, 2, WHITE_COLOR)

    total_ships := len(app.game.level_manager.enemies) + 1
    rl.DrawTextEx(font^, rl.TextFormat("ships=%d", total_ships), {5, 45}, 20, 2, WHITE_COLOR)

    total_ai := len(app.game.ai_collection)
    rl.DrawTextEx(font^, rl.TextFormat("ai=%d", total_ai), {5, 65}, 20, 2, WHITE_COLOR)

    total_xp := len(app.game.level_manager.exp_points)
    rl.DrawTextEx(font^, rl.TextFormat("xp=%d", total_xp), {5, 85}, 20, 2, WHITE_COLOR)

    total_hm := len(app.game.level_manager.hit_markers)
    rl.DrawTextEx(font^, rl.TextFormat("hm=%d", total_hm), {5, 105}, 20, 2, WHITE_COLOR)
}