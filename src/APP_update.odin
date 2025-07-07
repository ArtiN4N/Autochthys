package src

import rl "vendor:raylib"
import fmt "core:fmt"

APP_update :: proc(app: ^App) {
    switch &t in app.state {
    case APP_Game_State:
        GAME_update(&app.game)
    case APP_Menu_State:
        MENU_update(app.curr_menu)
    case APP_Inventory_State:
        INVENTORY_update(&app.game)
    case APP_Transition_State:
        TRANSITION_update(app, &t)
    case APP_Debug_State:
        DEBUG_update(app)
    }
}