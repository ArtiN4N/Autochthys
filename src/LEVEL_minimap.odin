package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"

LEVEL_Minimap_Draw_Data :: struct {
    room_rects: [LEVEL_WORLD_ROOMS]rl.Rectangle
}

LEVEL_Minimap :: struct {
    visualizer: rl.RenderTexture2D,
    width, height: f32,
    start_pixel: IVector,
    discovered_rooms: bit_set[0..<LEVEL_WORLD_ROOMS],
    centered_pixel: IVector,
    draw_data: LEVEL_Minimap_Draw_Data,
}

LEVEL_minimap_move_focus :: proc(w: ^LEVEL_World, room: LEVEL_Room_World_Index) {
    r_rect := w.minimap.draw_data.room_rects[room]
    w.minimap.centered_pixel = to_ivector(FVector{r_rect.x, r_rect.y})
    LEVEL_minimap_discover_room(w, room)
}

LEVEL_minimap_discover_room :: proc(w: ^LEVEL_World, room: LEVEL_Room_World_Index) {
    w.minimap.discovered_rooms += {int(room)}

    LEVEL_minimap_draw(w, &w.minimap, int(room))
}

LEVEL_destroy_minimap_D :: proc(mm: ^LEVEL_Minimap) {
    rl.UnloadRenderTexture(mm.visualizer)

    log.infof("Minimap data destroyed")
}

LEVEL_MINIMAP_ROOM_SIZE :: 12
LEVEL_MINIMAP_DOOR_SIZE :: 4

LEVEL_create_minimap_A :: proc(mm: ^LEVEL_Minimap, world: ^LEVEL_World, room_vector_set: ^map[IVector]LEVEL_Room_World_Index) {
    min_vec, max_vec: IVector

    for vec, room_idx in room_vector_set {
        if vec.x < min_vec.x do min_vec.x = vec.x
        if vec.x > max_vec.x do max_vec.x = vec.x

        if vec.y < min_vec.y do min_vec.y = vec.y
        if vec.y > max_vec.y do max_vec.y = vec.y
    }

    rooms_width  := f32(max_vec.x - min_vec.x)
    rooms_height := f32(max_vec.y - min_vec.y)

    cell_size := LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2

    mm.width  = (rooms_width + 2) * (LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2)
    mm.height = (rooms_height + 2) * (LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2)

    tw, th := i32(mm.width), i32(mm.height)

    mm.visualizer = rl.LoadRenderTexture(tw, th)
    rl.SetTextureWrap(mm.visualizer.texture, rl.TextureWrap.CLAMP)

 
    mm.start_pixel.x = (abs(min_vec.x) + 1) * cell_size
    mm.start_pixel.y = (abs(min_vec.y) + 1) * cell_size

    //mm.start_pixel = IVECTOR_ZERO - (min_vec * (LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2) + LEVEL_MINIMAP_ROOM_SIZE)
    mm.centered_pixel = mm.start_pixel

    LEVEL_minimap_discover_room(world, world.start_room)

    LEVEL_create_minimap_rects(mm, world)
    LEVEL_minimap_draw(world, mm, 4)
}

LEVEL_create_minimap_rects :: proc(mm: ^LEVEL_Minimap, world: ^LEVEL_World) {
    cur_room := world.rooms[world.start_room]

    b_set := bit_set[0..<LEVEL_WORLD_ROOMS]{}
    b_set += {int(world.start_room)}

    LEVEL_create_minimap_rects_helper(world, cur_room, mm.start_pixel, &b_set)
}

LEVEL_minimap_offset_by_travel_dir :: proc(dir: LEVEL_Room_Connection) -> (off: IVector) {
    off = IVECTOR_ZERO
    switch dir {
    case .North:
        off.y -= LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2
    case .South:
        off.y += LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2
    case .West:
        off.x -= LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2
    case .East:
        off.x += LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2
    }
    return off
}

LEVEL_minimap_offset_by_door_dir :: proc(dir: LEVEL_Room_Connection, pos, size: FVector) -> (rpos, rsize: FVector) {
    rpos = pos
    rsize = size

    switch dir {
    case .North:
        rsize.y *= 2
        rpos.y -= rsize.y
        rpos.x += LEVEL_MINIMAP_ROOM_SIZE / 2 - rsize.x / 2
    case .South:
        rsize.y *= 2
        rpos.y += LEVEL_MINIMAP_ROOM_SIZE
        rpos.x += LEVEL_MINIMAP_ROOM_SIZE / 2 - rsize.x / 2
    case .West:
        rsize.x *= 2
        rpos.x -= rsize.x
        rpos.y += LEVEL_MINIMAP_ROOM_SIZE / 2 - rsize.y / 2
    case .East:
        rsize.x *= 2
        rpos.x += LEVEL_MINIMAP_ROOM_SIZE
        rpos.y += LEVEL_MINIMAP_ROOM_SIZE / 2 - rsize.y / 2
    }
    return rpos, rsize
}

LEVEL_create_minimap_rects_helper :: proc(
    world: ^LEVEL_World, room: LEVEL_Room, pos: IVector,
    clear_bit_set: ^bit_set[0..<LEVEL_WORLD_ROOMS],
) {
    clear_bit_set^ += {int(room.world_idx)}

    dsize := FVector{LEVEL_MINIMAP_ROOM_SIZE, LEVEL_MINIMAP_ROOM_SIZE}
    dpos := to_fvector(pos) - dsize / 2
    drect := rl.Rectangle{dpos.x, dpos.y, dsize.x, dsize.y}
    world.minimap.draw_data.room_rects[room.world_idx] = drect

    for w, dir in room.warps {
        if w == -1 || int(w) in clear_bit_set do continue 

        new_room := world.rooms[w]

        off := LEVEL_minimap_offset_by_travel_dir(dir)
        new_pos := pos + off
        
        LEVEL_create_minimap_rects_helper(world, new_room, new_pos, clear_bit_set)
    }
}

LEVEL_minimap_draw :: proc(world: ^LEVEL_World, mm: ^LEVEL_Minimap, cur_room: int) {
    rl.BeginTextureMode(mm.visualizer)
    defer rl.EndTextureMode()

    rl.ClearBackground(WHITE_COLOR)

    for r in 0..<len(mm.draw_data.room_rects) {
        if r not_in mm.discovered_rooms && APP_global_app.game.item_manager.key_items[.Charm] == 0 do continue

        room := world.rooms[r]
        c := BLACK_COLOR

        switch t in room.type {
        case LEVEL_Passive_Room:
            c = HITMARKER_2_COLOR
        case LEVEL_Aggressive_Room:
            c = rl.Color{u8(100 + 155 * (f32(t.aggression_level) / 6)), 30, 30, 255}
        case LEVEL_Boss_Room:
            c = rl.PURPLE
        case LEVEL_Mini_Boss_Room:
            c = rl.GREEN
        }

        if room.is_miniboss {
            c = rl.PURPLE
        }

        //if int(room.world_idx) == cur_room do c = EXP_COLOR

        rect := mm.draw_data.room_rects[r]
        rl.DrawRectangleRec(rect, c)

        if int(room.world_idx) == cur_room {
            rad := rect.width / 4
            rl.DrawCircle(i32(rect.x + rect.width / 2), i32(rect.y + rect.height / 2), rad, EXP_COLOR)
        }
        
        for crm, dir in room.warps {
            if crm == -1 do continue

            cc := rl.Color{0, 0, 0, 40}
    
            cpos := FVector{rect.x, rect.y}
            csize := FVector{LEVEL_MINIMAP_DOOR_SIZE, LEVEL_MINIMAP_DOOR_SIZE}
            cpos, csize = LEVEL_minimap_offset_by_door_dir(dir, cpos, csize)
    
            crect := rl.Rectangle{cpos.x, cpos.y, csize.x, csize.y}    
            rl.DrawRectangleRec(crect, cc)
        }
    }
}