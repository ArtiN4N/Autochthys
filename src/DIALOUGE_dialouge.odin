package src

import rl "vendor:raylib"
import fmt "core:fmt"
import queue "core:container/queue"
import strings "core:strings"

DIALOUGE_LINE_DELAY :: 0.5

DIALOUGE_Text_Data :: struct {
    color: rl.Color,
    bold: bool,
    line: int,
    text: string,
    opt: int,
}

DIALOUGE_Delay :: struct {
    opt: int,
    char: int,
    time: f32,
}

DIALOUGE_Data :: struct {
    len: int,
    cur_opt: int,

    bounce_elapsed: f32,
    bounce_time: f32,

    elapsed: f32,
    char_lag: f32,
    cur_char: int,

    delay_time: f32,
    delay_elapsed: f32,
    delays: queue.Queue(DIALOUGE_Delay),

    animating: bool,

    cur_string: string,

    real_strings: [dynamic]DIALOUGE_Text_Data,
    max_chars: [dynamic]int,
}

DIALOUGE_clear_real_strings_D :: proc(data: ^DIALOUGE_Data) {
    for &s in &data.real_strings {
        delete(s.text)
    }
    clear(&data.real_strings)
    clear(&data.max_chars)

    queue.clear(&data.delays)
}

DIALOUGE_global_destroy_dialouge_state_D :: proc(app: ^App) {
    a_state, _ := &APP_global_app.state.(APP_Dialouge_State)
    DIALOUGE_clear_real_strings_D(&a_state.data)
    delete(a_state.data.real_strings)
    delete(a_state.data.max_chars)

    queue.destroy(&a_state.data.delays)
}

DIALOUGE_global_generate_dialouge_state_A :: proc() -> APP_Dialouge_State {
    // this will probably have some complex logic and thus offshooting functions to determine the correct npc -> dialouge instance
    state: APP_Dialouge_State

    text := INTERACTION_global_get_dialouge_text_array()

    state.data.len = len(text^)
    state.data.cur_opt = 0
    state.data.elapsed = 0
    state.data.cur_char = 0
    state.data.animating = true

    state.data.char_lag = 0.05
    state.data.bounce_time = 0.1
    state.data.bounce_elapsed = 0

    queue.init(&state.data.delays)

    state.data.real_strings = make([dynamic]DIALOUGE_Text_Data)
    state.data.max_chars = make([dynamic]int)
    DIALOUGE_generate_parsed_string_A(&state.data, text)

    return state
}

DIALOUGE_update :: proc(app: ^App) {
    a_state, _ := &APP_global_app.state.(APP_Dialouge_State)
    d_data := &a_state.data

    a_man := INTERACTION_global_get_dialouge_anim_manager()
    ANIMATION_update_manager(a_man)

    if queue.len(d_data.delays) > 0 {
        d := queue.front(&d_data.delays)
        
        if d_data.cur_opt == d.opt && d_data.cur_char == d.char {
            d_data.delay_time = d.time
            queue.pop_front(&d_data.delays)
        }
    }

    if d_data.delay_time > 0 {
        if d_data.delay_elapsed >= d_data.delay_time {
            d_data.delay_time = 0
            d_data.delay_elapsed = 0
        } else {
            d_data.delay_elapsed += dt
            return
        }
    }

    //text animation
    if d_data.animating {

        if d_data.bounce_elapsed >= d_data.bounce_time {
            d_data.bounce_elapsed = 0
        }
        
        if d_data.elapsed >= d_data.char_lag {
            d_data.cur_char += 1
            d_data.elapsed = 0

            char: u8 = 'a'
            char_count := 0
            for dtext_data in d_data.real_strings {
                if dtext_data.opt != d_data.cur_opt do continue
                if d_data.cur_char <= char_count + len(dtext_data.text) {
                    idx := d_data.cur_char - char_count
                    char = dtext_data.text[idx-1]
                    break
                }

                char_count += len(dtext_data.text)
            }

            if char != ' ' do SOUND_global_fx_manager_play_tag(INTERACTION_global_get_dialouge_text_sound())
        }
        d_data.elapsed += dt
        d_data.bounce_elapsed += dt
    }

    if d_data.cur_char == d_data.max_chars[d_data.cur_opt] {
        d_data.animating = false
        d_data.elapsed = 0
    }

    if !rl.IsKeyPressed(.E) do return
    

    if d_data.animating {
        d_data.animating = false
        d_data.elapsed = 0
        d_data.cur_char = d_data.max_chars[d_data.cur_opt]
        return
    }
    d_data.cur_opt += 1


    if d_data.cur_opt == d_data.len {
        DIALOUGE_global_destroy_dialouge_state_D(app)
        TRANSITION_set(.Dialouge, .Game)
        return
    }

    d_data.cur_char = 0
    d_data.elapsed = 0
    d_data.animating = true

    text := INTERACTION_global_get_dialouge_text_array()
}

DIALOUGE_draw :: proc(render_man: ^APP_Render_Manager, app: ^App) {
    a_state, _ := &app.state.(APP_Dialouge_State)

    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)

    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    box_width  : f32 = 640
    box_height : f32 = 128

    obox_width  : f32 = 640 + 10
    obox_height : f32 = 128 + 10

    dbox := rl.Rectangle{(rw - box_width) / 2, rh - box_height - 32 - 5, box_width, box_height}
    outline := rl.Rectangle{(rw - obox_width) / 2, rh - obox_height - 32, obox_width, obox_height}


    a_man := INTERACTION_global_get_dialouge_anim_manager()

    size := a_man.collection.animations[.ANIMATION_IDLE_TAG].sheet_size * 4

    speech_bounce := (a_state.data.bounce_elapsed / a_state.data.bounce_time) * 5
    npc_draw_rect := Rect{(rw - obox_width) / 2 + 50, rh - obox_height - 32 - 2 * f32(size.y) / 3 - 20 - speech_bounce, f32(size.x), f32(size.y)}

    dest_frame := to_rl_rect(ANIMATION_manager_get_dest_frame(a_man, npc_draw_rect))
    src_frame := to_rl_rect(ANIMATION_manager_get_src_frame(a_man))
    dest_origin := ANIMATION_manager_get_dest_origin(a_man, dest_frame)

    
    tex_sheet := a_man.collection.entity_type
    rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, to_rl_rect(npc_draw_rect), dest_origin, 0, rl.WHITE)
    DIALOUGE_draw_box(&a_state.data, dbox, outline)
}

DIALOUGE_draw_box :: proc(data: ^DIALOUGE_Data, dbox, outline: rl.Rectangle) {

    rl.DrawRectangleRec(outline, WHITE_COLOR)
    rl.DrawRectangleRec(dbox, BLACK_COLOR)

    DIALOUGE_draw_lines(data, dbox)
}

DIALOUGE_draw_lines :: proc(data: ^DIALOUGE_Data, dbox: rl.Rectangle) {

    text := INTERACTION_global_get_dialouge_text_array()

    DIALOUGE_animate_text(data, text^[data.cur_opt], {dbox.x, dbox.y})
}

DIALOUGE_animate_text :: proc(data: ^DIALOUGE_Data, str: string, spos: FVector) {
    

    //draw_str := DIALOUGE_get_parsed_string(data)[:data.cur_char]
    DIALOUGE_draw_parsed_string(data, spos)
    
}

DIALOUGE_draw_parsed_string :: proc(data: ^DIALOUGE_Data, spos: FVector) {
    char_count := 0
    font := APP_get_global_default_font()
    bfont := APP_get_global_default_font(true)

    chosen_font: ^rl.Font = font

    spos := spos + {10, 10}

    off_pos := FVECTOR_ZERO
    last_line := 0

    for dtext_data in data.real_strings {
        if dtext_data.opt != data.cur_opt do continue
        if data.cur_char <= char_count do continue

        if dtext_data.bold do chosen_font = bfont 
        else do chosen_font = font 

        draw_str := dtext_data.text
        if data.cur_char <= char_count + len(draw_str) {
            idx := data.cur_char - char_count
            draw_str = draw_str[0:idx]
        }

        tsize := rl.MeasureTextEx(chosen_font^, rl.TextFormat("%s", draw_str), 40, 2)

        if dtext_data.line > last_line {
            last_line += 1
            off_pos.y += tsize.y
            off_pos.x = 0
        }

        rl.DrawTextEx(chosen_font^, rl.TextFormat("%s", draw_str), spos + off_pos, 40, 2, dtext_data.color)

        off_pos.x += tsize.x

        char_count += len(dtext_data.text)
    }
    
}

DIALOUGE_generate_parsed_string_A :: proc(data: ^DIALOUGE_Data, strs: ^[]string) {
    DIALOUGE_clear_real_strings_D(data)

    builder := strings.builder_make()

    bold_flag := false
    color_flag := WHITE_COLOR
    cur_line := 0
    cur_opt := 0

    for str in strs^ {
        append(&data.max_chars, 0)

        cur_line = 0

        c_idx := 0
        for c_idx < len(str) {

            char := str[c_idx]

            if char == '*' {
                if strings.builder_len(builder) > 0 {
                    str_res := strings.to_string(builder)
                    real_data := DIALOUGE_Text_Data{
                        color_flag,
                        bold_flag,
                        cur_line,
                        strings.clone(str_res),
                        cur_opt,
                    }
                    append(&data.real_strings, real_data)
                    strings.builder_reset(&builder)

                    bold_flag = !bold_flag
                } else do bold_flag = true
            }
            else if char == '^' {
                //write final string on this line
                str_res := strings.to_string(builder)
                real_data := DIALOUGE_Text_Data{
                    color_flag,
                    bold_flag,
                    cur_line,
                    strings.clone(str_res),
                    cur_opt,
                }
                append(&data.real_strings, real_data)
                strings.builder_reset(&builder)

                delay := DIALOUGE_Delay{
                    cur_opt,
                    data.max_chars[cur_opt],
                    DIALOUGE_LINE_DELAY
                }
                queue.push(&data.delays, delay)

                cur_line += 1
            }
            else if char == '@' {
                if strings.builder_len(builder) > 0 {
                    str_res := strings.to_string(builder)

                    real_data := DIALOUGE_Text_Data{
                        color_flag,
                        bold_flag,
                        cur_line,
                        strings.clone(str_res),
                        cur_opt,
                    }
                    append(&data.real_strings, real_data)
                    strings.builder_reset(&builder)
                }

                parsed_color := strings.builder_make()

                search_idx := c_idx + 1
                for str[search_idx] != '<' {
                    strings.write_byte(&parsed_color, str[search_idx])
                    search_idx += 1
                    c_idx += 1
                }

                switch strings.to_string(parsed_color) {
                case "red":
                    color_flag = rl.RED
                case "blue":
                    color_flag = rl.BLUE
                case:
                    color_flag = WHITE_COLOR
                }

                strings.builder_destroy(&parsed_color)
            }
            else if char == '<' {

            }
            else if char == '>' {
                //write final string for color
                str_res := strings.to_string(builder)
                real_data := DIALOUGE_Text_Data{
                    color_flag,
                    bold_flag,
                    cur_line,
                    strings.clone(str_res),
                    cur_opt,
                }
                append(&data.real_strings, real_data)
                strings.builder_reset(&builder)

                color_flag = rl.WHITE
            }
            else {
                strings.write_byte(&builder, char)
                data.max_chars[cur_opt] += 1
            }

            c_idx += 1
        }

        defer cur_opt += 1

        if strings.builder_len(builder) <= 0 do continue

        str_res := strings.to_string(builder)
        real_data := DIALOUGE_Text_Data{
            color_flag,
            bold_flag,
            cur_line,
            strings.clone(str_res),
            cur_opt,
        }
        append(&data.real_strings, real_data)
        strings.builder_reset(&builder)

        
    }

    strings.builder_destroy(&builder)
}