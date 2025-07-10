package src

import rl "vendor:raylib"

Menu :: struct {
    info_rect: Rect,
    velocity: FVector,
}

MENU_update :: proc(menu: ^Menu) {
    rw, rh := APP_get_global_render_size()

    menu.info_rect = rect_add_vector(menu.info_rect, menu.velocity * dt)

    if menu.info_rect.x < 0 {
        menu.info_rect.x = 0
        menu.velocity.x *= -1
    } else if menu.info_rect.x + menu.info_rect.w > f32(rw) {
        menu.info_rect.x = f32(rw) - menu.info_rect.w
        menu.velocity.x *= -1
    }

    if menu.info_rect.y < 0 {
        menu.info_rect.y = 0
        menu.velocity.y *= -1
    } else if menu.info_rect.y + menu.info_rect.h > f32(rh) {
        menu.info_rect.y = f32(rh) - menu.info_rect.h
        menu.velocity.y *= -1
    }

    if rl.IsKeyPressed(.X) do TRANSITION_set(.Menu, .Game)
}

MENU_draw :: proc(render_man: ^APP_Render_Manager, menu: ^Menu) {
    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(WHITE_COLOR)

    font := APP_get_global_font(.Dialouge24_reg)
    rl.DrawTextEx(font^, "MAIN MENU -- press x to start", get_rect_pos(menu.info_rect) + {1, 1}, 24, 2, BLACK_COLOR)
}