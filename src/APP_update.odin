package src

import rl "vendor:raylib"
import fmt "core:fmt"

APP_update :: proc(app: ^App) {
    switch &t in app.state {
    case APP_Game_State:
        if app.save_manager.new {
            app.save_manager.new = false
            INTERACTION_trigger_event(&app.game.interaction_manager, .Tutorial)
        } else do GAME_update(&app.game)
    case APP_Menu_State:
        MENU_update(app.curr_menu)
    case APP_Inventory_State:
        INVENTORY_update(&app.game)
    case APP_Transition_State:
        TRANSITION_update(app, &t)
    case APP_Dialouge_State:
        DIALOUGE_update(app)
    case APP_Debug_State:
        DEBUG_update(app)
    }

    SOUND_global_music_manager_update()

    // we do this in case any transitions are 0 seconds
    if t, ok := &app.state.(APP_Transition_State); ok {
        if t.time == 0 do TRANSITION_update(app, t)
    }
}