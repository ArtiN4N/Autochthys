package src

import rl "vendor:raylib"
import fmt "core:fmt"

SAVEPOINT_setup_menu :: proc(menu: ^Menu) {
    rw, rh := APP_get_global_render_size()

    menu.color = UI_COLOR
    menu.top_left = FVECTOR_ZERO
    menu.size = FVector{f32(rw), f32(rh)}

    menu.y_margin = 5
    menu.x_margin = 5

    menu.elements = make([dynamic]MENU_Element)
    menu.created = true
    ui_font_ptr := APP_get_global_font(.Dialouge24_reg)
    
    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Return",
            text_color = UI_COLOR,
            text_hover_color = UI_COLOR,
            text_clicked_color = WHITE_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {160, 30},
            rect_color = WHITE_COLOR,
            rect_hover_color = AMMO_HUD_COLOR,
            rect_clicked_color = AMMO_HUD_COLOR,

            callback = proc() {
                SAVEPOINT_global_destroy_savepoint_state_D(&APP_global_app)
                TRANSITION_set(.Savepoint, .Game)
            },
        },
        offset = {0, 0}
    })
}