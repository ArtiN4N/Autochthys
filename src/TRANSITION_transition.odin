package src

import rl "vendor:raylib"

TRANSITION_finish :: proc(app: ^App, state: APP_Transition_State) {
    switch state.to {
    case .Game:
        app.state = APP_Game_State{}
    case .Menu:
        app.state = APP_Menu_State{}
    case .Inventory:
        app.state = APP_Inventory_State{}
    }
}

TRANSITION_update :: proc(app: ^App, state: ^APP_Transition_State) {
    if state.elapsed >= state.time {
        TRANSITION_finish(app, state^)
    }

    state.elapsed += dt
}

TRANSITION_draw :: proc(render_man: ^APP_Render_Manager, app: ^App, state: APP_Transition_State) {
    if state.from == .Game || state.to == .Game {
        GAME_draw(render_man, &app.game)
    }
        
    if state.from == .Menu || state.to == .Menu {
        MENU_draw(render_man, app.curr_menu)
    }

    if state.from == .Inventory || state.to == .Inventory {
        INVENTORY_draw(render_man, &app.game)
    }
}