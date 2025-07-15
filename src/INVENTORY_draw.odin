package src

import rl "vendor:raylib"
import fmt "core:fmt"

INVENTORY_draw :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    iman := &APP_global_app.game.inventory_manager
    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    rw, rh := f32(render_man.render_width), f32(render_man.render_height)
    tlx, tly := rw * 0.25 * 0.5, rh * 0.25 * 0.5

    canvas_rec := rl.Rectangle{ tlx, tly, rw * 0.75, rh * 0.75}
    rl.DrawRectangleRec(canvas_rec, UI_COLOR)

    

    switch iman.cur_page {
    case .Map:
        INVENTORY_draw_map(canvas_rec)
    case .Items:
        INVENTORY_draw_items(canvas_rec)
    case .Stats:
    case .Quests:
    }

    MENU_draw(&APP_global_app.menu)

    OTHER_draw_ui(render_man)
}

INVENTORY_draw_map :: proc(canvas: rl.Rectangle) {
    mmap := &APP_global_app.game.current_world.minimap
    center := to_fvector(mmap.centered_pixel)
    source       := rl.Rectangle{0, 0, mmap.width, -mmap.height}
    dest         := rl.Rectangle{canvas.x + 10, canvas.y + 10, mmap.width, mmap.height}
    origin       := rl.Vector2{0, 0}
    rotation: f32 = 0
    tint         := rl.WHITE
    
    rl.DrawTexturePro(
        mmap.visualizer.texture,
        source, dest, origin, rotation, tint
    )
}

INVENTORY_draw_items :: proc(canvas: rl.Rectangle) {
    item_manager := &APP_global_app.game.item_manager

    off_x: f32 = canvas.x + 10
    off_y: f32 = canvas.y + 10

    x_margin: f32 = 10
    y_margin: f32 = 10

    max_row_y: f32 = 0

    ui_font_ptr := APP_get_global_font(.Dialouge24_reg)

    cursor := APP_global_get_screen_mouse_pos()

    draw_tooltip := false
    tooltip_size, tooltip_pos := FVECTOR_ZERO, FVECTOR_ZERO
    tooltip_id: ITEM_type
    tooltip_cstr: cstring
    any_items := false

    for item_count, id in item_manager.key_items {
        if item_count <= 0 do continue

        any_items = true

        anim := &item_manager.anim_managers[id]

        src_frame := to_rl_rect(ANIMATION_manager_get_src_frame(anim))
        real_rect := Rect{off_x, off_y, src_frame.width, src_frame.height}
        dest_frame := to_rl_rect(ANIMATION_manager_get_dest_frame(anim, real_rect))
        dest_origin := ANIMATION_manager_get_dest_origin(anim, dest_frame)

        

        if dest_frame.height > max_row_y do max_row_y = dest_frame.height
        
        tex_sheet := anim.collection.entity_type
        rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, 0, rl.WHITE)

        text_pos := FVector{off_x + src_frame.width - 5, off_y + src_frame.height - 5}
        rl.DrawTextEx(ui_font_ptr^, rl.TextFormat("x%v", item_count), text_pos, 24, 2, rl.WHITE)
        

        //desc
        if rect_contains_vec(real_rect, cursor) {
            draw_tooltip = true

            

            tooltip_id = id
        }

        off_x += x_margin + dest_frame.width + 10
        if off_x > canvas.x + canvas.width - 10 {
            off_x = canvas.x + 10
            off_x += max_row_y + y_margin
            max_row_y = 0
        }
    }

    if draw_tooltip {
        tooltip_rect := rl.Rectangle{canvas.x + canvas.width / 2, canvas.y - 30, 0, 0}
        tooltip_size = rl.MeasureTextEx(ui_font_ptr^, rl.TextFormat("%v", ITEM_type_to_name[tooltip_id]), 24, 2)
        tooltip_rect.width = tooltip_size.x + 10
        tooltip_rect.height = tooltip_size.y + 10
        tooltip_rect.x -= tooltip_rect.width / 2

        tooltip_pos = FVector{tooltip_rect.x + (tooltip_rect.width - tooltip_size.x) / 2, tooltip_rect.y + (tooltip_rect.height - tooltip_size.y) / 2}

        rl.DrawRectangleRec(tooltip_rect, {255,255,255,200})
        rl.DrawTextEx(ui_font_ptr^, rl.TextFormat("%v", ITEM_type_to_name[tooltip_id]), tooltip_pos, 24, 2, BLACK_COLOR)
    }

    if !any_items {
        text_pos := FVector{off_x, off_y}
        rl.DrawTextEx(ui_font_ptr^, "No Items", text_pos, 24, 2, DMG_COLOR)
    }
}