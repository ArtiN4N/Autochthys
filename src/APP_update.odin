package src

import rl "vendor:raylib"
import fmt "core:fmt"

APP_update_debug :: proc(app: ^App) {
    
}

APP_update :: proc(app: ^App) {
    switch &t in app.state {
    case APP_Game_State:
        GAME_update(&app.game)
    case APP_Menu_State:
        MENU_update(app.curr_menu)
    case APP_Transition_State:
        TRANSITION_update(app, &t)
    case nil:
    }

    when ODIN_DEBUG { APP_draw_debug(app) }
}