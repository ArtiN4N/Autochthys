package src

import rl "vendor:raylib"
import fmt "core:fmt"

INVENTORY_setup_menu_stats :: proc(menu: ^Menu) {
    rw, rh := APP_get_global_render_size()

    menu.color = UI_COLOR
    menu.top_left = FVECTOR_ZERO
    menu.size = FVector{f32(rw), f32(rh)}

    menu.y_margin = 5
    menu.x_margin = 5

    menu.elements = make([dynamic]MENU_Element)
    menu.created = true
    title_font_ptr := APP_get_global_font(.Title48)
    ui_font_ptr := APP_get_global_font(.Dialouge24_reg)
    credit_font_ptr := APP_get_global_font(.Dialouge20_reg)

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Born of",
            color = WHITE_COLOR,
            font = title_font_ptr,
            fsize = 48,
        },
        offset = {100, 100}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = APP_global_app.game.stats_manager.boon_title,
            color = rl.RED,
            font = title_font_ptr,
            fsize = 48,
        },
        offset = {282, -48 - 5}
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
                MENU_set_menu(&APP_global_app.menu, .Menu_Inventory)
            },
        },
        offset = {100, 0}
    })


    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(int){
            text = MENU_Text{
                text = "Level   --  %v",
                color = WHITE_COLOR,
                font = credit_font_ptr,
                fsize = 20,
            },
            arg = &APP_global_app.game.stats_manager.level
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Level",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(int){
            text = MENU_Text{
                text = "Points  --  %v",
                color = WHITE_COLOR,
                font = credit_font_ptr,
                fsize = 20,
            },
            arg = &APP_global_app.game.stats_manager.points
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Points",
            color = HITMARKER_2_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(f32){
            text = MENU_Text{
                text = "XP      --  %.0f",
                color = WHITE_COLOR,
                font = credit_font_ptr,
                fsize = 20,
            },
            arg = &APP_global_app.game.stats_manager.experience
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "XP",
            color = EXP_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(f32){
            text = MENU_Text{
                text = "Req XP  --  %.0f",
                color = WHITE_COLOR,
                font = credit_font_ptr,
                fsize = 20,
            },
            arg = &APP_global_app.game.stats_manager.experience
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Req XP",
            color = EXP_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })
    
    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(f32){
            text = MENU_Text{
                text = "Health  --  %.0f",
                color = WHITE_COLOR,
                font = credit_font_ptr,
                fsize = 20,
            },
            arg = &APP_global_app.game.stats_manager.max_hp
        },
        offset = {100, 20}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Health",
            color = DMG_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "",
            text_color = APP_RENDER_CLEAR_COLOR,
            text_hover_color = APP_RENDER_CLEAR_COLOR,
            text_clicked_color = APP_RENDER_CLEAR_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {14, 14},
            rect_color = HITMARKER_2_COLOR,
            rect_hover_color = EXP_COLOR,
            rect_clicked_color = WHITE_COLOR,

            callback = proc() {
                STATS_global_player_level_up_hp()
            },
        },
        offset = {250, -25 + 2}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(f32){
            text = MENU_Text{
                text = "Damage  --  %.0f",
                color = WHITE_COLOR,
                font = credit_font_ptr,
                fsize = 20,
            },
            arg = &APP_global_app.game.stats_manager.dmg
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Damage",
            color = rl.PURPLE,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "",
            text_color = APP_RENDER_CLEAR_COLOR,
            text_hover_color = APP_RENDER_CLEAR_COLOR,
            text_clicked_color = APP_RENDER_CLEAR_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {14, 14},
            rect_color = HITMARKER_2_COLOR,
            rect_hover_color = EXP_COLOR,
            rect_clicked_color = WHITE_COLOR,

            callback = proc() {
                STATS_global_player_level_up_dmg()
            },
        },
        offset = {250, -25 + 2}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Formatted_Text(f32){
            text = MENU_Text{
                text = "Speed   --  %.0f",
                color = WHITE_COLOR,
                font = credit_font_ptr,
                fsize = 20,
            },
            arg = &APP_global_app.game.stats_manager.speed
        },
        offset = {100, 0}
    })
    append(&menu.elements, MENU_Element{
        ele = MENU_Text{
            text = "Speed",
            color = SPEED_COLOR,
            font = credit_font_ptr,
            fsize = 20,
        },
        offset = {100, -25}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "",
            text_color = APP_RENDER_CLEAR_COLOR,
            text_hover_color = APP_RENDER_CLEAR_COLOR,
            text_clicked_color = APP_RENDER_CLEAR_COLOR,
            font = ui_font_ptr,
            fsize = 24,

            size = {14, 14},
            rect_color = HITMARKER_2_COLOR,
            rect_hover_color = EXP_COLOR,
            rect_clicked_color = WHITE_COLOR,

            callback = proc() {
                STATS_global_player_level_up_speed()
            },
        },
        offset = {250, -25 + 2}
    })
}

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
            text_color = WHITE_COLOR,
            text_hover_color = BLACK_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
            size = FVector{100, 30},
            rect_color = APP_RENDER_CLEAR_COLOR,
            rect_hover_color = APP_RENDER_CLEAR_COLOR,
            rect_clicked_color = APP_RENDER_CLEAR_COLOR,
            callback = proc() {
                INVENTORY_global_set_page(.Map)
            }
        },
        offset = FVECTOR_ZERO
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Items",
            text_color = WHITE_COLOR,
            text_hover_color = BLACK_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
            size = FVector{100, 30},
            rect_color = APP_RENDER_CLEAR_COLOR,
            rect_hover_color = APP_RENDER_CLEAR_COLOR,
            rect_clicked_color = APP_RENDER_CLEAR_COLOR,
            callback = proc() {
                INVENTORY_global_set_page(.Items)
            }
        },
        offset = FVector{120, -36}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Stats",
            text_color = WHITE_COLOR,
            text_hover_color = BLACK_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
            size = FVector{100, 30},
            rect_color = APP_RENDER_CLEAR_COLOR,
            rect_hover_color = APP_RENDER_CLEAR_COLOR,
            rect_clicked_color = APP_RENDER_CLEAR_COLOR,
            callback = proc() {
                MENU_set_menu(&APP_global_app.menu, .Menu_Inventory_Stats)
                //INVENTORY_global_set_page(.Stats)
            }
        },
        offset = FVector{240, -36}
    })

    append(&menu.elements, MENU_Element{
        ele = MENU_Button{
            label = "Warp to Spawn",
            text_color = WHITE_COLOR,
            text_hover_color = BLACK_COLOR,
            text_clicked_color = DMG_COLOR,
            font = ui_font_ptr,
            fsize = 24,
            size = FVector{195, 30},
            rect_color = APP_RENDER_CLEAR_COLOR,
            rect_hover_color = APP_RENDER_CLEAR_COLOR,
            rect_clicked_color = APP_RENDER_CLEAR_COLOR,
            callback = proc() {
                LEVEL_global_warp_to_spawn()
            }
        },
        offset = FVector{360, -36}
    })
}