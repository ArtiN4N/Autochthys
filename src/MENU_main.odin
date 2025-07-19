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
                if global_skip_intro do TRANSITION_set(.Menu, .Game)
                else do INTRO_global_event()
            },
        },
        offset = {0, 20}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Instructions",
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
                MENU_set_menu(&APP_global_app.menu, .Menu_instructions)
            },
        },
        offset = {0, 0}
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
                MENU_set_menu(&APP_global_app.menu, .Menu_main_settings)
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

MENU_setup_main_settings :: proc(menu: ^Menu) {
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
            text = "Settings",
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
        ele = MENU_Formatted_Text(f32){
            text = MENU_Text{
                text = "Master Volume = %.1f",
                color = BLACK_COLOR,
                font = ui_font_ptr,
                fsize = 24
            },
            arg = &APP_global_app.master_volume
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "", font = ui_font_ptr, size = {10, 10},
            rect_color = EXP_COLOR, rect_hover_color = BLACK_COLOR, rect_clicked_color = UI_COLOR,
            callback = proc() {
                if APP_global_app.master_volume != 1 {
                    NOTIFICATION_global_add("+ 0.1", FVector{25, 45} + {230, -29} + {0, 78}, EXP_COLOR, FVector{0, -1})
                }
                APP_set_volume(&APP_global_app, 0.1)
            },
        },
        offset = {230, -29}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "", font = ui_font_ptr, size = {10, 10},
            rect_color = DMG_COLOR, rect_hover_color = BLACK_COLOR, rect_clicked_color = UI_COLOR,
            callback = proc() {
                if APP_global_app.master_volume != 0 {
                    NOTIFICATION_global_add("- 0.1", FVector{25, 49} + {230, -29} + {0, 78}, DMG_COLOR, FVector{0, -1})
                }
                APP_set_volume(&APP_global_app, -0.1)
            },
        },
        offset = {230, -1}
    })
    
    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(f32){
            text = MENU_Text{
                text = "Music Volume  = %.1f",
                color = BLACK_COLOR,
                font = ui_font_ptr,
                fsize = 24
            },
            arg = &APP_global_app.music_manager.volume
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "", font = ui_font_ptr, size = {10, 10},
            rect_color = EXP_COLOR, rect_hover_color = BLACK_COLOR, rect_clicked_color = UI_COLOR,
            callback = proc() {
                if APP_global_app.music_manager.volume != 1 {
                    NOTIFICATION_global_add("+ 0.1", FVector{25, 54 + 15} + {230, -29} + {0, 78}, EXP_COLOR, FVector{0, -1})
                }
                SOUND_set_music_volume(&APP_global_app.music_manager, 0.1)
            },
        },
        offset = {230, -29}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "", font = ui_font_ptr, size = {10, 10},
            rect_color = DMG_COLOR, rect_hover_color = BLACK_COLOR, rect_clicked_color = UI_COLOR,
            callback = proc() {
                if APP_global_app.music_manager.volume != 0 {
                    NOTIFICATION_global_add("- 0.1", FVector{25, 58 + 15} + {230, -29} + {0, 78}, DMG_COLOR, FVector{0, -1})
                }
                SOUND_set_music_volume(&APP_global_app.music_manager, -0.1)
            },
        },
        offset = {230, -1}
    })
    
    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(f32){
            text = MENU_Text{
                text = "SFX Volume    = %.1f",
                color = BLACK_COLOR,
                font = ui_font_ptr,
                fsize = 24
            },
            arg = &APP_global_app.sfx_manager.volume
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "", font = ui_font_ptr, size = {10, 10},
            rect_color = EXP_COLOR, rect_hover_color = BLACK_COLOR, rect_clicked_color = UI_COLOR,
            callback = proc() {
                if APP_global_app.sfx_manager.volume != 1 {
                    NOTIFICATION_global_add("+ 0.1", FVector{25, 67 + 40} + {230, -29} + {0, 78}, EXP_COLOR, FVector{0, -1})
                }
                SOUND_set_fx_volume(&APP_global_app.sfx_manager, 0.1)
            },
        },
        offset = {230, -29}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "", font = ui_font_ptr, size = {10, 10},
            rect_color = DMG_COLOR, rect_hover_color = BLACK_COLOR, rect_clicked_color = UI_COLOR,
            callback = proc() {
                if APP_global_app.sfx_manager.volume != 0 {
                    NOTIFICATION_global_add("- 0.1", FVector{25, 71 + 40} + {230, -29} + {0, 78}, DMG_COLOR, FVector{0, -1})
                }
                SOUND_set_fx_volume(&APP_global_app.sfx_manager, -0.1)
            },
        },
        offset = {230, -1}
    })

    
    
}