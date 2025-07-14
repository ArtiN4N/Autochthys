package src

import rl "vendor:raylib"
import fmt "core:fmt"

// App state is what the application is currently doing
// can be three values: game, menu and transition
// menu and game are self explanitory
// transition moves between one state to another

// We use a union of structs here to simulate an enum, so that we can include some state specific data
// like transition data for the transition state
APP_State :: union{
    APP_Game_State, APP_Menu_State, APP_Transition_State,
    APP_Debug_State, APP_Inventory_State, APP_Dialouge_State,
    APP_Savepoint_State, APP_Intro_State, APP_Outro_State,
}

// functional state just includes states that have functional behaviour in the application
// is used by the transition state to determine what to show to the screen
APP_Functional_State :: enum{ Entry, Game, Menu, Inventory, Dialouge, Savepoint, Intro, Outro, }

APP_SAVEPOINT_DIALOUGE_TO_MENU_TIME :: 0.1
APP_Savepoint_State :: struct {
    dialouge_data: DIALOUGE_Data,
    in_dialouge: bool,
    dialouge_to_menu_elapsed: f32,
}

APP_Dialouge_State :: struct {
    data: DIALOUGE_Data,
}

APP_Outro_State :: struct {
    dialouge_data: DIALOUGE_Data,
    in_dialouge: bool,
    hovered: [2]bool,
}

APP_Intro_State :: struct {
    dialouge_data: DIALOUGE_Data,
    in_dialouge: bool,
    hovered: [7]bool,
}

APP_Game_State :: struct {}
APP_Inventory_State :: struct {}
APP_Menu_State :: struct {}

// provides debugging / testing tools
APP_Debug_State :: struct {
    original_state: APP_Functional_State,
}

// Transition state has transitions from a functional state to another
// and lasts a specified amount of time
APP_Transition_State :: struct {
    from, to: APP_Functional_State,
    time, elapsed: f32,
}

APP_Static_Transition_Data :: struct {
    from_tex, to_tex: rl.RenderTexture2D,
    warp_dir: LEVEL_Room_Connection,
}

APP_create_static_transition_data_A :: proc(data: ^APP_Static_Transition_Data, rw, rh: i32) {
    data.from_tex = rl.LoadRenderTexture(rw, rh)
    data.to_tex = rl.LoadRenderTexture(rw, rh)
}

APP_destroy_static_transition_data_A :: proc(data: ^APP_Static_Transition_Data) {
    rl.UnloadRenderTexture(data.from_tex)
    rl.UnloadRenderTexture(data.to_tex)
}

APP_create_transition_state :: proc(
    from, to: APP_Functional_State, time: f32,
) -> APP_Transition_State {
    return { from, to, time, 0 }
}

APP_unlock_cursor :: proc() {
    rl.EnableCursor()
    APP_global_app.cursor_locked = false
}

APP_lock_cursor :: proc() {
    if APP_global_app.cursor_locked do return

    APP_global_app.cursor_locked = true
    rw, rh := APP_get_global_render_size()
    rl.SetMousePosition(i32(rw / 2), i32(rh / 2))
    rl.DisableCursor()
}

APP_global_get_screen_mouse_pos :: proc() -> FVector {
    man := &APP_global_app.render_manager

    xoffset := APP_global_get_render_from_screen_offset()
    offset_pos := rl.GetMousePosition() - {xoffset.x, 0}
    return offset_pos / man.render_scale
}

APP_global_get_render_from_screen_offset :: proc() -> FVector {
    man := &APP_global_app.render_manager
    sw, sh := CONFIG_get_global_screen_size()
    rw, rh := APP_get_global_render_size()

    return {(f32(sw) - f32(rw) * man.render_scale) / 2, 0}
}