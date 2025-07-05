package src

import rl "vendor:raylib"
import math "core:math"

GAME_update_cursor :: proc(game: ^Game) {
    dm := rl.GetMouseDelta()
    game.cursor_position += dm

    rw, rh := APP_get_global_render_size()
    game.cursor_position = vector_clamp(game.cursor_position, 0, f32(rw), 0, f32(rh))
}

GAME_draw_cursor :: proc(pos: FVector) {
    // draws an x reticle
    start_dist: f32 = 2
    end_dist: f32 = 10

    theta1: f32 = math.PI / 4
    theta2: f32 = 3 * math.PI / 4
    theta3: f32 = 5 * math.PI / 4
    theta4: f32 = 7 * math.PI / 4

    rl.DrawLineEx(
        start_dist * FVector{math.cos(theta1), math.sin(theta1)} + pos,
        end_dist * FVector{math.cos(theta1), math.sin(theta1)} + pos,
        2,
        BLACK_COLOR
    )

    rl.DrawLineEx(
        start_dist * FVector{math.cos(theta2), math.sin(theta2)} + pos,
        end_dist * FVector{math.cos(theta2), math.sin(theta2)} + pos,
        2,
        BLACK_COLOR
    )

    rl.DrawLineEx(
        start_dist * FVector{math.cos(theta3), math.sin(theta3)} + pos,
        end_dist * FVector{math.cos(theta3), math.sin(theta3)} + pos,
        2,
        BLACK_COLOR
    )

    rl.DrawLineEx(
        start_dist * FVector{math.cos(theta4), math.sin(theta4)} + pos,
        end_dist * FVector{math.cos(theta4), math.sin(theta4)} + pos,
        2,
        BLACK_COLOR
    )
}