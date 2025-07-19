package src

import rl "vendor:raylib"
import fmt "core:fmt"

MENU_setup_instructions1 :: proc(menu: ^Menu) {
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
            text = "Instructions 1/2",
            color = BLACK_COLOR,
            font = title_font_ptr,
            fsize = 48,
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Return",
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
                MENU_set_menu(&APP_global_app.menu, .Menu_main)
            },
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Next",
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
                MENU_set_menu(&APP_global_app.menu, .Menu_instructions2)
            },
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "W A S D To move character",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 20}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Move mouse to aim",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 20}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Hold left click to shoot",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "You have a limited number of shots before you must reload",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Press R to reload early",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Right click to parry certain bullets right before they hit you",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 20}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Only pink bullets can be parried",
            color = PARRY_BULLET_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = FVECTOR_ZERO
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "If you miss a parry, you must wait for it to recharge",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Parried bullets recover health",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = FVECTOR_ZERO
    })

}

MENU_setup_instructions2 :: proc(menu: ^Menu) {
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
            text = "Instructions 2/2",
            color = BLACK_COLOR,
            font = title_font_ptr,
            fsize = 48,
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Return",
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
                MENU_set_menu(&APP_global_app.menu, .Menu_main)
            },
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Previous",
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
                MENU_set_menu(&APP_global_app.menu, .Menu_instructions1)
            },
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "ESCAPE to open settings",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "You cannot open settings in battle",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "TAB to open inventory",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "You can warp to spawn from inventory",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Collected items will appear in inventory",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "You cannot open inventory in battle",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Kill enemies to collect experience",
            color = EXP_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Select stats in inventory to spend experience to grow stronger",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Inventory contains a full-sized map",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Inventory map shows a green dot on current room",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Purple map rooms contain a difficult challenge",
            color = rl.PURPLE,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Blue map rooms are passive and contain npcs",
            color = HITMARKER_2_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "E to interact with npcs",
            color = BLACK_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {0, 0}
    })
}