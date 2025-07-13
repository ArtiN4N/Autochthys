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

    mmap := &game.current_world.minimap
    center := to_fvector(mmap.centered_pixel)
    source       := rl.Rectangle{0, 0, mmap.width, -mmap.height}
    dest         := rl.Rectangle{100, 100, mmap.width, mmap.height}
    origin       := rl.Vector2{0, 0}
    rotation: f32 = 0
    tint         := rl.WHITE

    
    rl.DrawTexturePro(
        mmap.visualizer.texture,
        source, dest, origin, rotation, tint
    )

    GAME_draw_cursor(game.cursor_position)
    OTHER_draw_ui(render_man)
}