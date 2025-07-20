package src

import rl "vendor:raylib"
import fmt "core:fmt"

MENU_setup_instructions1 :: proc(menu: ^Menu) {
    rw, rh := APP_get_global_render_size()

    menu.color = UI_COLOR
    menu.top_left = FVECTOR_ZERO
    menu.size = FVector{f32(rw), f32(rh)}

    menu.y_margin = 5
    menu.x_margin = 5

    menu.elements = make([dynamic]MENU_Element)
    menu.created = true
    main_title_ptr := APP_get_global_font(.MainTitle128)
    title_font_ptr := APP_get_global_font(.Title48)
    ui_font_ptr := APP_get_global_font(.Dialouge24_reg)
    credit_font_ptr := APP_get_global_font(.Dialouge20_reg)

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Autochthys",
            color = WHITE_COLOR,
            font = main_title_ptr,
            fsize = 128,
        },
        offset = {100, 100}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "ver.ALPHA",
            color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {100, -30}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Next",
            text_color = WHITE_COLOR,
            text_hover_color = BLACK_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {45, 30},
            rect_color = APP_RENDER_CLEAR_COLOR,
            rect_hover_color = APP_RENDER_CLEAR_COLOR,
            rect_clicked_color = APP_RENDER_CLEAR_COLOR,

            callback = proc() {
                MENU_set_menu(&APP_global_app.menu, .Menu_instructions2)
            },
        },
        offset = {100, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Keys W A S D       --  Move character",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "     W A S D",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Key R              --  Reload",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 10}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "    R",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Hold Left Click    --  Fire bullets",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "     Left Click",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Press Right Click  --  Parry bullet",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "      Right Click",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Key E              --  Progress dialouge",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "    E",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Key Z              --  Skip dialouge",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "    Z",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Key X              --  Increase dialouge speed",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "    X",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Key E              --  Interact with NPCs",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "    E",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Key TAB            --  Open inventory",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "    TAB",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Key ESC            --  Open settings",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "    ESC",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

}

MENU_setup_instructions2 :: proc(menu: ^Menu) {
    rw, rh := APP_get_global_render_size()

    menu.color = UI_COLOR
    menu.top_left = FVECTOR_ZERO
    menu.size = FVector{f32(rw), f32(rh)}

    menu.y_margin = 5
    menu.x_margin = 5

    menu.elements = make([dynamic]MENU_Element)
    menu.created = true
    main_title_ptr := APP_get_global_font(.MainTitle128)
    title_font_ptr := APP_get_global_font(.Title48)
    ui_font_ptr := APP_get_global_font(.Dialouge24_reg)
    credit_font_ptr := APP_get_global_font(.Dialouge20_reg)

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Autochthys",
            color = WHITE_COLOR,
            font = main_title_ptr,
            fsize = 128,
        },
        offset = {100, 100}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "ver.ALPHA",
            color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
        },
        offset = {100, -30}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Return",
            text_color = WHITE_COLOR,
            text_hover_color = BLACK_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {68, 30},
            rect_color = APP_RENDER_CLEAR_COLOR,
            rect_hover_color = APP_RENDER_CLEAR_COLOR,
            rect_clicked_color = APP_RENDER_CLEAR_COLOR,

            callback = proc() {
                MENU_set_menu(&APP_global_app.menu, .Menu_main)
            },
        },
        offset = {100, 0}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Only pink bullets can be parried",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "     pink",
            color = PARRY_BULLET_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Parried bullets recover health",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "                        health",
            color = DMG_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "If you miss a parry, you must wait to parry again",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "                              wait",
            color = PARRY_BULLET_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Parries must be timed right before",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "                      right",
            color = DMG_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "being hit with a bullet",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -5}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "You cannot open settings or inventory in battle",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "The inventory contains a map, items, the ability to",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "level up, and the ability to warp to your spawn",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -5}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Eliminate enemies to collect experience",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Eliminate",
            color = DMG_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Rooms on the map are color coded",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "The green dot shows where you are",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "    green",
            color = EXP_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Red rooms are hostile",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Red",
            color = DMG_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Blue rooms are passive and contain npcs",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Blue",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Purple rooms contain a difficult challenge",
            color = WHITE_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Purple",
            color = rl.PURPLE,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
}