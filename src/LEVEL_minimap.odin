package src

import rl "vendor:raylib"
import fmt "core:fmt"

LEVEL_Minimap :: struct {
    visualizer: rl.RenderTexture2D,
    width, height: f32,
    start_pixel_x, start_pixel_y: int,
    discovered_rooms: bit_set[0..<LEVEL_WORLD_ROOMS],
}

LEVEL_minimap_discover_room :: proc(w: ^LEVEL_World, room: LEVEL_Room_World_Index) {
    w.minimap.discovered_rooms += {int(room)}
    LEVEL_draw_world_visualizer_helper(&w.minimap, w)
}

LEVEL_destroy_minimap_D :: proc(mm: ^LEVEL_Minimap) {
    rl.UnloadRenderTexture(mm.visualizer)
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
    
    mm.width  = (rooms_width + 2) * LEVEL_MINIMAP_ROOM_SIZE + (rooms_width) * LEVEL_MINIMAP_DOOR_SIZE * 2
    mm.height = (rooms_height + 2) * LEVEL_MINIMAP_ROOM_SIZE + (rooms_height) * LEVEL_MINIMAP_DOOR_SIZE * 2

    tw, th := i32(mm.width), i32(mm.height)

    mm.visualizer = rl.LoadRenderTexture(tw, th)

    mm.start_pixel_x = 0 - min_vec.x * (LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2) + LEVEL_MINIMAP_ROOM_SIZE
    mm.start_pixel_y = 0 - min_vec.y * (LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2) + LEVEL_MINIMAP_ROOM_SIZE

    mm.discovered_rooms += {int(world.start_room)}

    LEVEL_draw_world_visualizer_helper(mm, world)
}

LEVEL_draw_world_visualizer_helper :: proc(mm: ^LEVEL_Minimap, world: ^LEVEL_World) {
    rl.BeginTextureMode(mm.visualizer)
    defer rl.EndTextureMode()

    rl.ClearBackground(WHITE_COLOR)

    cur_room := world.rooms[world.start_room]

    b_set := bit_set[0..<LEVEL_WORLD_ROOMS]{}
    b_set += {int(world.start_room)}

    LEVEL_write_world_visualizer_helper(world, cur_room, mm.start_pixel_x, mm.start_pixel_y, &b_set)
}

LEVEL_write_world_visualizer_helper :: proc(
    world: ^LEVEL_World, room: LEVEL_Room, x, y: int,
    clear_bit_set: ^bit_set[0..<LEVEL_WORLD_ROOMS],
) {
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

    rl.DrawRectangle(i32(x) - LEVEL_MINIMAP_ROOM_SIZE / 2, i32(y) - LEVEL_MINIMAP_ROOM_SIZE / 2, LEVEL_MINIMAP_ROOM_SIZE, LEVEL_MINIMAP_ROOM_SIZE, c)

    for crm, dir in room.warps {
        if crm == - 1 do continue
        cc := rl.Color{0, 0, 0, 40}

        cx := x
        cy := y

        cw: i32 = LEVEL_MINIMAP_DOOR_SIZE
        ch: i32 = LEVEL_MINIMAP_DOOR_SIZE

        switch dir {
        case .North:
            cy -= LEVEL_MINIMAP_DOOR_SIZE * 3
            ch *= 2
        case .South:
            cy += LEVEL_MINIMAP_DOOR_SIZE * 2
            ch *= 2
        case .West:
            cx -= LEVEL_MINIMAP_DOOR_SIZE * 3
            cw *= 2
        case .East:
            cx += LEVEL_MINIMAP_DOOR_SIZE * 2
            cw *= 2
            
        }

        rl.DrawRectangle(i32(cx) - LEVEL_MINIMAP_DOOR_SIZE / 2, i32(cy) - LEVEL_MINIMAP_DOOR_SIZE / 2, cw, ch, cc)
    }


    for w, dir in room.warps {
        if w == -1 || int(w) in clear_bit_set || int(w) not_in world.minimap.discovered_rooms { continue }

        clear_bit_set^ += {int(w)}

        new_room := world.rooms[w]
        new_x := x
        new_y := y
        switch dir {
        case .North:
            new_y -= LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2
        case .South:
            new_y += LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2
        case .West:
            new_x -= LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2
        case .East:
            new_x += LEVEL_MINIMAP_ROOM_SIZE + LEVEL_MINIMAP_DOOR_SIZE * 2
        }
        LEVEL_write_world_visualizer_helper(world, new_room, new_x, new_y, clear_bit_set)
    }
}