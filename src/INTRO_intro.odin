package src

import rl "vendor:raylib"
import fmt "core:fmt"
import rand "core:math/rand"

global_skip_intro :: false

INTRO_global_event :: proc() {
    man := &APP_global_app.game.interaction_manager

    man.set_dialouge_array = DIALOUGE_global_finder_intro()
    man.set_dialouge_sound = .Man_Voice

    TRANSITION_set(.Menu, .Intro)
}

INTRO_clear_real_strings_D :: proc(state: ^APP_Intro_State) {
    DIALOUGE_clear_real_strings_D(&state.dialouge_data)
}

INTRO_global_destroy_intro_state_D :: proc(app: ^App) {
    a_state, _ := app.state.(APP_Intro_State)

    DIALOUGE_destroy_dialouge_data(&a_state.dialouge_data)
}

INTRO_global_generate_intro_state_A :: proc() -> APP_Intro_State {
    // this will probably have some complex logic and thus offshooting functions to determine the correct npc -> dialouge instance
    state: APP_Intro_State

    DIALOUGE_global_generate_dialouge_data_A(&state.dialouge_data)
    state.in_dialouge = true

    return state
}

INTRO_draw_dialouge :: proc(data: ^DIALOUGE_Data) {
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

INTRO_build_arrs :: proc(
    font: ^rl.Font, opos: FVector,
    text_arr: ^[7]cstring, off_arr: ^[7]FVector, pos_arr: ^[7]FVector, rect_arr: ^[7]Rect
) {
    text_arr^ = {
        "greed", "gluttony",
        "envy", "pride",
        "sloth", "wrath",
        "lust"
    }
    off_arr^ = {
        {-50, 80},
        {50, 80},
        {-100, 150},
        {100, 150},
        {-50, 220},
        {50, 220},
        {0, 150}
    }

    for i in 0..<7 {
        text := text_arr[i]
        off := off_arr[i]
        ssize := rl.MeasureTextEx(font^, text, 24, 2)

        draw_pos := opos + off
        draw_pos.x -= ssize.x / 2

        pos_arr[i] = draw_pos

        rect_arr[i] = Rect{draw_pos.x, draw_pos.y, ssize.x, ssize.y}
    }
}

INTRO_draw_boons :: proc() {
    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)
    chosen_font := APP_get_global_font(.Dialouge24_reg)

    sinpos := FVector{rw / 2, 60 + 50}

    sins := [7]cstring{}
    sin_offs := [7]FVector{}
    sin_draw_pos := [7]FVector{}
    sin_rects := [7]Rect{}

    hover_idx := -1

    INTRO_build_arrs(chosen_font, sinpos, &sins, &sin_offs, &sin_draw_pos, &sin_rects)
    
    for i in 0..<7 {
        cursor := APP_global_get_render_mouse_pos()
        if !rect_contains_vec(sin_rects[i], cursor) do continue

        hover_idx = i
    }

    for i in 0..<7 {
        col := rl.WHITE
        draw_pos := sin_draw_pos[i]

        if hover_idx == i {
            col = rl.RED
            draw_pos += vector_normalize({rand.float32() - 0.5, rand.float32() - 0.5} * 2) * 2
        }
        rl.DrawTextEx(chosen_font^, sins[i], draw_pos, 24, 2, col)
    }

    sin_tool_tips := [][2]cstring{
        {"+ 50% xp","- 50% hp"},//greed
        {"+ 25% xp","- 25% speed"},//gluttony
        {"+ 25% speed","+ 25% foe speed"},//envy
        {"+ 50% damage","- 25% xp"},//pride
        {"+ 100% hp","- 50% speed"},//sloth
        {"+ 100% damage","+ 100% foe damage"},//wrath
        {"you want to fuck the fish","the fish want to fuck you"},//lust
    }

    tool_tip_off := FVector{0, 330}

    for i in 0..<len(sins) {
        if hover_idx != i do continue

        text_p := sin_tool_tips[i][0]
        text_n := sin_tool_tips[i][1]

        psize := rl.MeasureTextEx(chosen_font^, text_p, 24, 2)
        nsize := rl.MeasureTextEx(chosen_font^, text_n, 24, 2)

        draw_pos_p := sinpos + tool_tip_off + vector_normalize({rand.float32() - 0.5, rand.float32() - 0.5} * 2) * 1
        draw_pos_n := sinpos + tool_tip_off + {0, 50} + vector_normalize({rand.float32() - 0.5, rand.float32() - 0.5} * 2) * 1

        draw_pos_p.x -= psize.x / 2
        draw_pos_n.x -= nsize.x / 2

        pcolor := rl.BLUE
        ncolor := rl.RED

        if hover_idx == 6 {
            pcolor = rl.PURPLE
            ncolor = rl.PURPLE
        }

        rl.DrawTextEx(chosen_font^, text_p, draw_pos_p, 24, 2, pcolor)
        rl.DrawTextEx(chosen_font^, text_n, draw_pos_n, 24, 2, ncolor)
    }
}

INTRO_draw_transition :: proc(render_man: ^APP_Render_Manager, app: ^App) {
    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(rl.BLACK)
}

INTRO_draw :: proc(render_man: ^APP_Render_Manager, app: ^App) {
    a_state, _ := &app.state.(APP_Intro_State)

    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    //rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
    rl.ClearBackground(rl.BLACK)

    INTRO_draw_dialouge(&a_state.dialouge_data)
    if a_state.in_dialouge do return

    INTRO_draw_boons()
}

INTRO_update_dialogue :: proc(state: ^APP_Intro_State) {
    DIALOUGE_data_update(&state.dialouge_data)
    if state.dialouge_data.cur_opt == state.dialouge_data.len {
        state.in_dialouge = false
        state.dialouge_data.cur_opt -= 1
        state.dialouge_data.cur_char = state.dialouge_data.max_chars[state.dialouge_data.cur_opt]
    }
}

INTRO_update_selection :: proc(state: ^APP_Intro_State) {
    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)
    chosen_font := APP_get_global_font(.Dialouge24_reg)

    sinpos := FVector{rw / 2, 60 + 50}

    sins := [7]cstring{}
    sin_offs := [7]FVector{}
    sin_draw_pos := [7]FVector{}
    sin_rects := [7]Rect{}

    hover_idx := -1

    INTRO_build_arrs(chosen_font, sinpos, &sins, &sin_offs, &sin_draw_pos, &sin_rects)
    for i in 0..<7 {
        cursor := APP_global_get_render_mouse_pos()
        if !rect_contains_vec(sin_rects[i], cursor) {
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

    INTRO_global_destroy_intro_state_D(&APP_global_app)
    INTRO_selection_events[hover_idx]()
    SOUND_global_fx_manager_play_tag(.Menu_click)
}

INTRO_update :: proc(app: ^App) {
    a_state, _ := &APP_global_app.state.(APP_Intro_State)
    d_data := &a_state.dialouge_data

    if a_state.in_dialouge {
        INTRO_update_dialogue(a_state)
        return
    }

    INTRO_update_selection(a_state)
}