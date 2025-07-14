package src

import rl "vendor:raylib"
import fmt "core:fmt"
import rand "core:math/rand"

@(rodata)
DIALOUGE_OUTRO := []string{
    "...",
    "......",
    "Failure.",
    "...",
    "A reboot is imminent...",
    "...",
    "...^Then, with the time we have left...",
    "...",
    "Allow me to ask you some questions.",
    "...",
    "Was it not enough?",
    "Was the hate^not enough?",
    "...",
    "No answer.^Next.",
    "...",
    "Do you harbor^resentment?",
    "...",
    "Do you regret your creation?^...^Do you wish for revenge?",
    "...",
    "...",
    "...^Still,^no answer.",
    "...",
    "...",
    "Fine. Final question.^I have a feeling that you'll answer this one.",
    "...",
    "Do you wish to^...",
    "...",
    "Do you choose to^@red<#sin#>^again?",
}

DIALOUGE_global_finder_outro :: proc() -> ^[]string {
    return &DIALOUGE_OUTRO
}

OUTRO_global_event :: proc() {
    man := &APP_global_app.game.interaction_manager

    man.set_dialouge_array = DIALOUGE_global_finder_outro()
    man.set_dialouge_sound = .Man_Voice

    TRANSITION_set(.Game, .Outro)
}

OUTRO_clear_real_strings_D :: proc(state: ^APP_Outro_State) {
    DIALOUGE_clear_real_strings_D(&state.dialouge_data)
}

OUTRO_global_destroy_outro_state_D :: proc(app: ^App) {
    a_state, _ := app.state.(APP_Outro_State)

    DIALOUGE_destroy_dialouge_data(&a_state.dialouge_data)
}

OUTRO_global_generate_outro_state_A :: proc() -> APP_Outro_State {
    // this will probably have some complex logic and thus offshooting functions to determine the correct npc -> dialouge instance
    state: APP_Outro_State

    DIALOUGE_global_generate_dialouge_data_A(&state.dialouge_data)
    state.in_dialouge = true

    return state
}

OUTRO_update_dialogue :: proc(state: ^APP_Outro_State) {
    DIALOUGE_data_update(&state.dialouge_data)
    if state.dialouge_data.cur_opt == state.dialouge_data.len {
        state.in_dialouge = false
        state.dialouge_data.cur_opt -= 1
        state.dialouge_data.cur_char = state.dialouge_data.max_chars[state.dialouge_data.cur_opt]
    }
}

OUTRO_update_selection :: proc(state: ^APP_Outro_State) {
    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)
    chosen_font := APP_get_global_font(.Dialouge24_reg)

    hover_idx := -1


    choicepos := FVector{rw / 2, 60 + 50}

    choices := [2]cstring{}
    choices_offs := [2]FVector{}
    choices_draw_pos := [2]FVector{}
    choices_rects := [2]Rect{}

    
    OUTRO_build_arrs(chosen_font, choicepos, &choices, &choices_offs, &choices_draw_pos, &choices_rects)
    for i in 0..<2 {
        cursor := APP_global_get_render_mouse_pos()
        if !rect_contains_vec(choices_rects[i], cursor) {
            state.hovered[i] = false
            continue
        }

        if !state.hovered[i] {
            state.hovered[i] = true
            SOUND_global_fx_manager_play_tag(.Menu_hover)
        }

        hover_idx = i
    }
    
    if !rl.IsMouseButtonReleased(.LEFT) do return

    if hover_idx == -1 do return

    OUTRO_global_destroy_outro_state_D(&APP_global_app)
    SOUND_global_fx_manager_play_tag(.Menu_click)
    OUTRO_selection_events[hover_idx]()
}

OUTRO_update :: proc(app: ^App) {
    a_state, _ := &APP_global_app.state.(APP_Outro_State)
    d_data := &a_state.dialouge_data

    if a_state.in_dialouge {
        OUTRO_update_dialogue(a_state)
        return
    }

    OUTRO_update_selection(a_state)
}

OUTRO_draw_dialouge :: proc(data: ^DIALOUGE_Data) {
    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)

    text := INTERACTION_global_get_dialouge_text_array()
    ospos := FVector{rw / 2, 60} - {10, 10}
    spos := ospos

    if data.cur_opt == data.len - 1 {
        spos += vector_normalize({rand.float32() - 0.5, rand.float32() - 0.5} * 2) * 2
        rl.BeginBlendMode(.ADDITIVE)

        cpos := spos + {12, 22}
        rl.DrawCircleGradient(i32(cpos.x), i32(cpos.y), 60, {255, 0, 0, 77}, {255, 0, 0, 0})
    }

    DIALOUGE_draw_parsed_string(data, spos, true)

    if data.cur_opt == data.len - 1 {
        rl.EndBlendMode()
    }
}

OUTRO_draw :: proc(render_man: ^APP_Render_Manager, app: ^App) {
    a_state, _ := &app.state.(APP_Outro_State)

    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    //rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
    rl.ClearBackground(rl.BLACK)

    // ... im too pressed for time (im too lazy)
    OUTRO_draw_dialouge(&a_state.dialouge_data)
    if a_state.in_dialouge do return

    OUTRO_draw_choices()
}

OUTRO_draw_transition :: proc(render_man: ^APP_Render_Manager, app: ^App) {
    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(rl.BLACK)
}

OUTRO_draw_choices :: proc() {
    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)
    chosen_font := APP_get_global_font(.Dialouge24_reg)

    hover_idx := -1


    choicepos := FVector{rw / 2, 60 + 50}

    choices := [2]cstring{}
    choices_offs := [2]FVector{}
    choices_draw_pos := [2]FVector{}
    choices_rects := [2]Rect{}

    
    OUTRO_build_arrs(chosen_font, choicepos, &choices, &choices_offs, &choices_draw_pos, &choices_rects)
    for i in 0..<2 {
        cursor := APP_global_get_render_mouse_pos()
        if !rect_contains_vec(choices_rects[i], cursor) do continue

        hover_idx = i
    }

    for i in 0..<2 {
        col := rl.WHITE
        draw_pos := choices_draw_pos[i]

        if hover_idx == i {
            col = rl.RED
            draw_pos += vector_normalize({rand.float32() - 0.5, rand.float32() - 0.5} * 2) * 2
        }
        rl.DrawTextEx(chosen_font^, choices[i], draw_pos, 24, 2, col)
    }
}

OUTRO_build_arrs :: proc(
    font: ^rl.Font, opos: FVector,
    text_arr: ^[2]cstring, off_arr: ^[2]FVector, pos_arr: ^[2]FVector, rect_arr: ^[2]Rect
) {
    text_arr^ = {
        "yes", "no"
    }
    off_arr^ = {
        {-50, 80},
        {50, 80},
    }

    for i in 0..<2 {
        text := text_arr[i]
        off := off_arr[i]
        ssize := rl.MeasureTextEx(font^, text, 24, 2)

        draw_pos := opos + off
        draw_pos.x -= ssize.x / 2

        pos_arr[i] = draw_pos

        rect_arr[i] = Rect{draw_pos.x, draw_pos.y, ssize.x, ssize.y}
    }
}