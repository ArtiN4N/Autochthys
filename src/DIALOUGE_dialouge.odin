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

    default_color: rl.Color,
}

DIALOUGE_clear_real_strings_D :: proc(data: ^DIALOUGE_Data) {
    for &s in &data.real_strings {
        delete(s.text)
    }
    clear(&data.real_strings)
    clear(&data.max_chars)

    queue.clear(&data.delays)
}

DIALOUGE_destroy_dialouge_data :: proc(d: ^DIALOUGE_Data) {
    DIALOUGE_clear_real_strings_D(d)
    delete(d.real_strings)
    delete(d.max_chars)

    queue.destroy(&d.delays)
}

DIALOUGE_global_destroy_dialouge_state_D :: proc(app: ^App) {
    a_state, _ := app.state.(APP_Dialouge_State)
    DIALOUGE_destroy_dialouge_data(&a_state.data)
}

DIALOUGE_global_generate_dialouge_data_A :: proc(data: ^DIALOUGE_Data, dcolor: rl.Color = WHITE_COLOR) {
    // this will probably have some complex logic and thus offshooting functions to determine the correct npc -> dialouge instance
    text := INTERACTION_global_get_dialouge_text_array()

    data.len = len(text^)
    data.cur_opt = 0
    data.elapsed = 0
    data.cur_char = 0
    data.animating = true

    data.char_lag = 0.05
    data.bounce_time = 0.1
    data.bounce_elapsed = 0

    queue.init(&data.delays)

    data.default_color = dcolor

    data.real_strings = make([dynamic]DIALOUGE_Text_Data)
    data.max_chars = make([dynamic]int)
    DIALOUGE_generate_parsed_string_A(data, text)
}

DIALOUGE_global_generate_dialouge_state_A :: proc() -> APP_Dialouge_State {
    // this will probably have some complex logic and thus offshooting functions to determine the correct npc -> dialouge instance
    state: APP_Dialouge_State

    DIALOUGE_global_generate_dialouge_data_A(&state.data)

    return state
}

DIALOUGE_data_update :: proc(data: ^DIALOUGE_Data) {
    if queue.len(data.delays) > 0 {
        d := queue.front(&data.delays)
        
        if data.cur_opt == d.opt && data.cur_char == d.char {
            data.delay_time = d.time
            queue.pop_front(&data.delays)
        }
    }

    if data.delay_time > 0 {
        if data.delay_elapsed >= data.delay_time {
            data.delay_time = 0
            data.delay_elapsed = 0
        } else {
            data.delay_elapsed += dt
            return
        }
    }

    //text animation
    if data.animating {

        if data.bounce_elapsed >= data.bounce_time {
            data.bounce_elapsed = 0
        }
        
        if data.elapsed >= data.char_lag {
            data.cur_char += 1
            data.elapsed = 0

            char: u8 = 'a'
            char_count := 0
            for dtext_data in data.real_strings {
                if dtext_data.opt != data.cur_opt do continue
                if data.cur_char <= char_count + len(dtext_data.text) {
                    idx := data.cur_char - char_count
                    char = dtext_data.text[idx-1]
                    break
                }

                char_count += len(dtext_data.text)
            }

            if char != ' ' do SOUND_global_fx_manager_play_tag(INTERACTION_global_get_dialouge_text_sound())
        }
        data.elapsed += dt
        data.bounce_elapsed += dt
    }

    if data.cur_char == data.max_chars[data.cur_opt] {
        data.animating = false
        data.elapsed = 0
    }

    if !rl.IsKeyPressed(.E) do return
    

    if data.animating {
        data.animating = false
        data.elapsed = 0
        data.cur_char = data.max_chars[data.cur_opt]
        return
    }
    data.cur_opt += 1

    data.cur_char = 0
    data.elapsed = 0
    data.animating = true
}

DIALOUGE_update :: proc(app: ^App) {
    a_state, _ := &APP_global_app.state.(APP_Dialouge_State)
    d_data := &a_state.data

    a_man := INTERACTION_global_get_dialouge_anim_manager()
    ANIMATION_update_manager(a_man)

    
    DIALOUGE_data_update(d_data)

    //if !rl.IsKeyPressed(.E) do return
    if d_data.cur_opt == d_data.len {
        DIALOUGE_global_destroy_dialouge_state_D(app)
        TRANSITION_set(.Dialouge, .Game)
        return
    }    
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

    OTHER_draw_ui(render_man)
}

DIALOUGE_draw_box :: proc(data: ^DIALOUGE_Data, dbox, outline: rl.Rectangle) {

    rl.DrawRectangleRec(outline, WHITE_COLOR)
    rl.DrawRectangleRec(dbox, BLACK_COLOR)

    if !data.animating {
        cross_pos := FVector{dbox.x, dbox.y} + FVector{dbox.width, dbox.height}
        rl.DrawRectangleV(cross_pos - {30, 20}, {20, 10}, WHITE_COLOR)
        rl.DrawRectangleV(cross_pos - {20, 30}, {10, 20}, WHITE_COLOR)
    }

    DIALOUGE_draw_lines(data, dbox)
}

DIALOUGE_draw_lines :: proc(data: ^DIALOUGE_Data, dbox: rl.Rectangle) {
    text := INTERACTION_global_get_dialouge_text_array()

    DIALOUGE_draw_parsed_string(data, {dbox.x, dbox.y})
}

DIALOUGE_draw_parsed_string :: proc(data: ^DIALOUGE_Data, spos: FVector, centered: bool = false) {
    char_count := 0
    font := APP_get_global_font(.Dialouge24_reg)
    bfont := APP_get_global_font(.Dialouge24_bold)

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

        tsize := rl.MeasureTextEx(chosen_font^, rl.TextFormat("%s", draw_str), 24, 2)

        if dtext_data.line > last_line {
            last_line += 1
            off_pos.y += tsize.y
            off_pos.x = 0
        }

        draw_pos := spos + off_pos
        if centered {
            draw_pos.x -= tsize.x / 2
        }
        rl.DrawTextEx(chosen_font^, rl.TextFormat("%s", draw_str), draw_pos, 24, 2, dtext_data.color)

        off_pos.x += tsize.x

        char_count += len(dtext_data.text)
    }
    
}

DIALOUGE_generate_parsed_string_A :: proc(data: ^DIALOUGE_Data, strs: ^[]string) {
    DIALOUGE_clear_real_strings_D(data)

    builder := strings.builder_make()

    bold_flag := false
    color_flag := data.default_color
    cur_line := 0
    cur_opt := 0

    for str in strs^ {
        append(&data.max_chars, 0)

        cur_line = 0

        c_idx := 0
        for c_idx < len(str) {

            char := str[c_idx]

            if char == '#' {
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
                    color_flag = data.default_color
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

                color_flag = data.default_color
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