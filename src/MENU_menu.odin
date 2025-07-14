package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"

Menu :: struct {
    elements: [dynamic]MENU_Element,
    y_margin: f32,
    x_margin: f32,
    top_left: FVector,
    size: FVector,
    color: rl.Color,
    created: bool,
}

MENU_update :: proc(menu: ^Menu) {
    if !menu.created {
        log.warnf("Trying to update non-created menu")
        return
    }

    menu_position := menu.top_left + FVector{menu.x_margin, menu.y_margin}
    for &ele in &menu.elements {
        menu_position.y = MENU_update_element(&ele, menu_position)
        menu_position.y += menu.y_margin
    }
}

MENU_draw :: proc(menu: ^Menu) {
    if !menu.created {
        log.warnf("Trying to draw non-created menu")
        return
    }

    rl.DrawRectangleV(menu.top_left, menu.size, menu.color)

    menu_position := menu.top_left + FVector{menu.x_margin, menu.y_margin}
    for &ele in &menu.elements {
        menu_position.y = MENU_draw_element(&ele, menu_position)
        menu_position.y += menu.y_margin
    }
}

MENU_state_draw :: proc(render_man: ^APP_Render_Manager, app: ^App) {
    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    MENU_draw(&app.menu)
    OTHER_draw_ui(render_man)
}