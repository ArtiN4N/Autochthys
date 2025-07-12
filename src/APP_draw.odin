package src

import rl "vendor:raylib"
import fmt "core:fmt"

APP_draw :: proc(app: ^App) {
    //rl.ClearBackground(WHITE_COLOR)

    switch t in app.state {
    case APP_Game_State:
        GAME_draw(&app.render_manager, &app.game)
    case APP_Menu_State:
        MENU_state_draw(&app.render_manager, app)
    case APP_Inventory_State:
        INVENTORY_draw(&app.render_manager, &app.game)
    case APP_Transition_State:
    case APP_Dialouge_State:
        DIALOUGE_draw(&app.render_manager, app)
    case APP_Savepoint_State:
        SAVEPOINT_draw(&app.render_manager, app)
    case APP_Debug_State:
        DEBUG_draw(app)
    }

    when ODIN_DEBUG { DEBUG_draw(app) }
}