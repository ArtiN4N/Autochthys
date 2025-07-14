package src

import rl "vendor:raylib"
import fmt "core:fmt"

INVENTORY_setup_menu :: proc(menu: ^Menu) {
    _rw, _rh := APP_get_global_render_size()
    
    rw, rh := f32(_rw), f32(_rh)
    tlx, tly := rw * 0.25 * 0.5, rh * 0.25 * 0.5
    canvas_rec := rl.Rectangle{ tlx, tly, rw * 0.75, rh * 0.75}

    menu.color = UI_COLOR
    menu.top_left = {tlx, tly + canvas_rec.height - 42}
    menu.size = FVector{canvas_rec.width, 42}

    menu.y_margin = 6
    menu.x_margin = 10

    menu.elements = make([dynamic]MENU_Element)
    menu.created = true
    ui_font_ptr := APP_get_global_font(.Dialouge24_reg)
    
    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Map",
            text_color = UI_COLOR,
            text_hover_color = UI_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
            size = FVector{100, 30},
            rect_color = WHITE_COLOR,
            rect_hover_color = AMMO_HUD_COLOR,
            rect_clicked_color = AMMO_HUD_COLOR,
            callback = proc() {
                INVENTORY_global_set_page(.Map)
            }
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Items",
            text_color = UI_COLOR,
            text_hover_color = UI_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
            size = FVector{100, 30},
            rect_color = WHITE_COLOR,
            rect_hover_color = AMMO_HUD_COLOR,
            rect_clicked_color = AMMO_HUD_COLOR,
            callback = proc() {
                INVENTORY_global_set_page(.Items)
            }
        },
        offset = FVector{120, -36}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Stats",
            text_color = UI_COLOR,
            text_hover_color = UI_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
            size = FVector{100, 30},
            rect_color = WHITE_COLOR,
            rect_hover_color = AMMO_HUD_COLOR,
            rect_clicked_color = AMMO_HUD_COLOR,
            callback = proc() {
                INVENTORY_global_set_page(.Stats)
            }
        },
        offset = FVector{240, -36}
    })
}