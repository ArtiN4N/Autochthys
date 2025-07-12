package src

import rl "vendor:raylib"
import fmt "core:fmt"

MENU_DEFAULT_SPACING :: 2

MENU_draw_text_ele :: proc(txt: ^MENU_Text, pos: FVector) -> (next_y_pos: f32) {
    rl.DrawTextEx(txt.font^, txt.text, pos, txt.fsize, MENU_DEFAULT_SPACING, txt.color)
    return pos.y + txt.fsize
}

MENU_update_text_ele :: proc(txt: ^MENU_Text, pos: FVector) -> (next_y_pos: f32) {
    return pos.y + txt.fsize
}

MENU_Text :: struct {
    text: cstring,
    color: rl.Color,
    font: ^rl.Font,
    fsize: f32,
}

MENU_global_button_callback :: proc()

MENU_update_button_ele :: proc(but: ^MENU_Button, pos: FVector) -> (next_y_pos: f32) {
    button_rect := Rect{ pos.x, pos.y, but.size.x, but.size.y }

    cursor := APP_global_get_render_mouse_pos()
    if rect_contains_vec(button_rect, cursor) && rl.IsMouseButtonReleased(.LEFT) {
        but.callback()
    }

    return button_rect.y + but.size.y
}

MENU_draw_button_ele :: proc(but: ^MENU_Button, pos: FVector) -> (next_y_pos: f32) {
    button_rect := Rect{ pos.x, pos.y, but.size.x, but.size.y }
    button_r_middle := pos + but.size / 2

    text_bound_size := rl.MeasureTextEx(but.font^, but.label, but.fsize, MENU_DEFAULT_SPACING)
    text_position := button_r_middle - text_bound_size / 2

    rect_color := but.rect_color
    text_color := but.text_color

    cursor := APP_global_get_render_mouse_pos()
    if rect_contains_vec(button_rect, cursor) {
        rect_color = but.rect_hover_color
        text_color = but.text_hover_color

        if rl.IsMouseButtonDown(.LEFT) {
            rect_color = but.rect_clicked_color
            text_color = but.text_clicked_color
        }
    }

    rl.DrawRectangleRec(to_rl_rect(button_rect), rect_color)
    rl.DrawTextEx(but.font^, but.label, text_position, but.fsize, MENU_DEFAULT_SPACING, text_color)

    return button_rect.y + but.size.y
}

MENU_Button :: struct {
    label: cstring,
    text_color: rl.Color,
    text_hover_color: rl.Color,
    text_clicked_color: rl.Color,
    font: ^rl.Font,
    fsize: f32,

    size: FVector,
    rect_color: rl.Color,
    rect_hover_color: rl.Color,
    rect_clicked_color: rl.Color,

    callback: MENU_global_button_callback,
}

MENU_Element :: struct {
    ele: union { MENU_Text, MENU_Button },
    offset: FVector,
}

MENU_draw_element :: proc(element: ^MENU_Element, pos: FVector) -> (next_y_pos: f32) {
    switch &e in &element.ele {
    case MENU_Text:
        return MENU_draw_text_ele(&e, pos + element.offset)
    case MENU_Button:
        return MENU_draw_button_ele(&e, pos + element.offset)
    case:
    }
    return 0
}

MENU_update_element :: proc(element: ^MENU_Element, pos: FVector) -> (next_y_pos: f32) {
    switch &e in &element.ele {
    case MENU_Text:
        return MENU_update_text_ele(&e, pos + element.offset)
    case MENU_Button:
        return MENU_update_button_ele(&e, pos + element.offset)
    case:
    }

    return 0
}