package src

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

    return state
}

SAVEPOINT_update :: proc(app: ^App) {
    SOUND_global_music_log_tags()
}

SAVEPOINT_draw :: proc(render_man: ^APP_Render_Manager, app: ^App) {

}