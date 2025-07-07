package src

import rl "vendor:raylib"
import fmt "core:fmt"

APP_draw :: proc(app: ^App) {
    //rl.ClearBackground(WHITE_COLOR)

    switch t in app.state {
    case APP_Game_State:
        GAME_draw(&app.render_manager, &app.game)
    case APP_Menu_State:
        MENU_draw(&app.render_manager, app.curr_menu)
    case APP_Inventory_State:
        INVENTORY_draw(&app.render_manager, &app.game)
    case APP_Transition_State:
        TRANSITION_draw(&app.render_manager, app, t)
    case APP_Debug_State:
        DEBUG_draw(app)
    }

    when ODIN_DEBUG { DEBUG_draw(app) }
}