package src

import fmt "core:fmt"

MENU_setup_main :: proc(menu: ^Menu) {
    rw, rh := APP_get_global_render_size()

    menu.color = WHITE_COLOR
    menu.top_left = FVECTOR_ZERO
    menu.size = FVector{f32(rw), f32(rh)}

    menu.y_margin = 5
    menu.x_margin = 5

    menu.elements = make([dynamic]MENU_Element)
    menu.created = true
    title_font_ptr := APP_get_global_font(.Title48)
    ui_font_ptr := APP_get_global_font(.Dialouge24_reg)

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Fish Hell",
            color = BLACK_COLOR,
            font = title_font_ptr,
            fsize = 48,
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Start Game",
            text_color = WHITE_COLOR,
            text_hover_color = WHITE_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {160, 30},
            rect_color = BLACK_COLOR,
            rect_hover_color = UI_COLOR,
            rect_clicked_color = UI_COLOR,

            callback = proc() {
                TRANSITION_set(.Menu, .Game)
            },
        },
        offset = {0, 20}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Settings",
            text_color = WHITE_COLOR,
            text_hover_color = WHITE_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {160, 30},
            rect_color = BLACK_COLOR,
            rect_hover_color = UI_COLOR,
            rect_clicked_color = UI_COLOR,

            callback = proc() {
                fmt.printfln("fuck your settings")
            },
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Exit",
            text_color = WHITE_COLOR,
            text_hover_color = WHITE_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {160, 30},
            rect_color = BLACK_COLOR,
            rect_hover_color = UI_COLOR,
            rect_clicked_color = UI_COLOR,

            callback = proc() {
                APP_global_app.close = true
            },
        },
        offset = {0, 0}
    })
}