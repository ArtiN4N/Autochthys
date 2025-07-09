package src

import rl "vendor:raylib"
import fmt "core:fmt"

INVENTORY_draw :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    rw, rh := f32(render_man.render_width), f32(render_man.render_height)
    tlx, tly := rw * 0.25 * 0.5, rh * 0.25 * 0.5

    canvas_rec := rl.Rectangle{ tlx, tly, rw * 0.75, rh * 0.75}
    rl.DrawRectangleRec(canvas_rec, UI_COLOR)

    handle_rec := rl.Rectangle{ rw * 0.25 * 0.5 + rw * 0.75 * 0.33, rh * 0.75 + rh * 0.25 * 0.5 , rw * 0.75 * 0.33, rh * 0.25 * 0.5}
    rl.DrawRectangleRec(handle_rec, UI_COLOR)

    font := APP_get_global_default_font()
    rl.DrawTextEx(font^, "Fish fish fish fish fish fish fish fish", {tlx + 10, tly + 10}, 40, 2, WHITE_COLOR)

    rl.DrawTextEx(font^, rl.TextFormat("Level %d", game.player_stats.level), {tlx + 10, tly + 50}, 20, 2, EXP_COLOR)
    required_ex := STATS_level_up_equation(game.player_stats.level)
    rl.DrawTextEx(font^, rl.TextFormat("%d / %d omega-3", int(game.player_stats.experience), int(required_ex)), {tlx + 10, tly + 70}, 20, 2, EXP_COLOR)

    GAME_draw_cursor(game.cursor_position)
}