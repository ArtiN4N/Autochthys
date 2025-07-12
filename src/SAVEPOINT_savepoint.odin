package src

import rl "vendor:raylib"
import fmt "core:fmt"
import queue "core:container/queue"
import strings "core:strings"

SAVEPOINT_clear_real_strings_D :: proc(state: ^APP_Savepoint_State) {
    DIALOUGE_clear_real_strings_D(&state.dialouge_data)
}

SAVEPOINT_global_destroy_savepoint_state_D :: proc(app: ^App) {
    a_state, _ := app.state.(APP_Savepoint_State)

    DIALOUGE_destroy_dialouge_data(&a_state.dialouge_data)
}

SAVEPOINT_global_generate_savepoint_state_A :: proc() -> APP_Savepoint_State {
    // this will probably have some complex logic and thus offshooting functions to determine the correct npc -> dialouge instance
    state: APP_Savepoint_State

    DIALOUGE_global_generate_dialouge_data_A(&state.dialouge_data)
    state.in_dialouge = true

    return state
}

SAVEPOINT_update_dialogue :: proc(state: ^APP_Savepoint_State) {
    DIALOUGE_data_update(&state.dialouge_data)
    if state.dialouge_data.cur_opt == state.dialouge_data.len {
        state.in_dialouge = false
    }
}

SAVEPOINT_update :: proc(app: ^App) {
    a_state, _ := &APP_global_app.state.(APP_Savepoint_State)
    d_data := &a_state.dialouge_data

    if a_state.in_dialouge {
        SAVEPOINT_update_dialogue(a_state)
        return
    }

    MENU_update(&app.menu)
}

SAVEPOINT_draw_dialouge :: proc(data: ^DIALOUGE_Data) {
    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)
    
    box_width  : f32 = 640
    box_height : f32 = 128

    obox_width  : f32 = 640 + 10
    obox_height : f32 = 128 + 10

    dbox := rl.Rectangle{(rw - box_width) / 2, rh - box_height - 32 - 5, box_width, box_height}
    outline := rl.Rectangle{(rw - obox_width) / 2, rh - obox_height - 32, obox_width, obox_height}

    DIALOUGE_draw_box(data, dbox, outline)
}

SAVEPOINT_draw :: proc(render_man: ^APP_Render_Manager, app: ^App) {
    a_state, _ := &app.state.(APP_Savepoint_State)

    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    if a_state.in_dialouge {
        SAVEPOINT_draw_dialouge(&a_state.dialouge_data)
        return
    }

    MENU_draw(&app.menu)

    if a_state.dialouge_to_menu_elapsed < APP_SAVEPOINT_DIALOUGE_TO_MENU_TIME {
        a_state.dialouge_to_menu_elapsed += dt
    } else if a_state.dialouge_to_menu_elapsed > APP_SAVEPOINT_DIALOUGE_TO_MENU_TIME {
        a_state.dialouge_to_menu_elapsed = APP_SAVEPOINT_DIALOUGE_TO_MENU_TIME
    }
}