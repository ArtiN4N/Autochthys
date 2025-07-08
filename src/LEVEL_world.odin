package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import rand "core:math/rand"

LEVEL_WORLD_BLOCKS :: 3

LEVEL_World :: struct {
    rooms: [LEVEL_WORLD_ROOMS]LEVEL_Room,
    start_room: LEVEL_Room_World_Index,
    visualizer: rl.RenderTexture2D,
}

LEVEL_world_start_tag :: proc(world: ^LEVEL_World) -> LEVEL_Tag {
    return world.rooms[world.start_room].tag
}

LEVEL_apply_world_rooms_connection :: proc(
    world: ^LEVEL_World,
    from, to: LEVEL_Room_World_Index,
    from_dir: LEVEL_Room_Connection
) {
    world.rooms[from].warps[from_dir] = to
    world.rooms[to].warps[LEVEL_opposite_room_connection(from_dir)] = from
}

LEVEL_opposite_room_connection :: proc(dir: LEVEL_Room_Connection) -> LEVEL_Room_Connection {
    switch dir {
    case .North:
        return .South
    case .East:
        return .West
    case .South:
        return .North
    case .West:
        return .East
    }

    return .North
}

LEVEL_block_world_idx_offset_by_dir :: proc(dir: LEVEL_Room_Connection) -> LEVEL_Room_World_Index {
    ret := 1
    switch dir {
    case .North:
        ret = 1
    case .East:
        ret = 5
    case .South:
        ret = 7
    case .West:
        ret = 3
    }

    return cast(LEVEL_Room_World_Index) ret
}

LEVEL_create_world_room :: proc(
    world: ^LEVEL_World, room: LEVEL_Room_World_Index, tag: LEVEL_Tag, type: LEVEL_Room_Type = .Block, aggr: bool = true
) {
    r := &world.rooms[room]
    r.tag = tag
    r.aggression = aggr
    r.type = type
}

// this function generates a random world
LEVEL_create_world_A :: proc(world: ^LEVEL_World) {
    world.visualizer = rl.LoadRenderTexture(LEVEL_WORLD_ROOMS, LEVEL_WORLD_ROOMS)
    // a world consists of rooms connected to one another
    // all rooms must be accessible from all other rooms
    // rooms are connected to each other in the pattern of "blocks", "connectors", and "tails"

    // worlds contain LEVEL_WORLD_BLOCKS blocks, with 9 rooms each
    // 1 out of the LEVEL_WORLD_BLOCKS blocks will be a passive area, in which one of the rooms will connect to the boss door
    // blocks are connected by connectors, with 2-4 rooms each
    // counting the boss room, this totals for
    // 27 + 4/8 + 1 = 32-36 rooms
    // The total number of rooms is 46, which means tehre will be 10-14 rooms allocated for "tails"
    // tails are strings of rooms on the outskirts of the map and are linearly connected

    for i in 0..<LEVEL_WORLD_ROOMS {
        world.rooms[i].enemy_info = make([dynamic]LEVEL_room_enemy_info)
        for c in LEVEL_Room_Connection {
            world.rooms[i].warps[c] = LEVEL_NULL_ROOM
        }
    }

    //first, create the blocks
    blocks: [LEVEL_WORLD_BLOCKS]LEVEL_Room_World_Index
    passive_block: LEVEL_Room_World_Index
    passive_assigned := false
    total_room_count := 0

    for i in 0..<LEVEL_WORLD_BLOCKS {
        // try assigning the block to be passive
        passive_block_chance := rand.float32()
        is_passive := false
        if passive_block_chance <= (f32(i)+1) / LEVEL_WORLD_BLOCKS && !passive_assigned {
            is_passive = true
            passive_assigned = true
            passive_block = cast(LEVEL_Room_World_Index) total_room_count
        }

        // choose a block warp pattern
        block_warp_pattern := rand.choice(LEVEL_precomputed_room_blocks)
        for j in 0..<9 {
            // create each room
            room_idx := cast(LEVEL_Room_World_Index) total_room_count
            // the starting room in the starting block is always passive
            if i == 0 && j == 4 {
                LEVEL_create_world_room(world, room_idx, .Debug_L01, .Block, false)
                world.start_room = room_idx
            } else {
                LEVEL_create_world_room(world, room_idx, .Debug_L01, .Block, !is_passive)
            }

            // assign warps from room based on pattern
            for k in 0..<9 {
                if k == j do continue
                if block_warp_pattern[j][k] == 0 do continue
                // this is a valid warp

                // find the total room count for the warped room via this offset
                // it works since block rooms are added in order, together
                room_count_offset := k - j

                // find the direction of the warp (which wall its on)
                dir := LEVEL_Room_Connection.North
                if k == j - 1 do dir = .West
                if k == j + 1 do dir = .East
                if k == j + 3 do dir = .South

                from_idx := cast(LEVEL_Room_World_Index) total_room_count
                to_idx := cast(LEVEL_Room_World_Index) (total_room_count + room_count_offset)
                LEVEL_apply_world_rooms_connection(world, from_idx, to_idx, dir)
            }
            total_room_count += 1
        }
    }

    // next, connect the blocks via connectors

    // we use a temporary struct to combine a room index (the first room of the specific block),
    // and connection_directions array. this array has 4 values, one for each cardinal direction
    // it keeps track of which connections have been made to the block
    TEMP_Block_Connection :: struct {
        idx: LEVEL_Room_World_Index,
        connection_directions: [LEVEL_Room_Connection]bool,
    }

    // this dynamiclly allocated enum choice array is updated whenever we want to make a direction choice on an axis
    // we do this because 
    //rand_enum_choice := make([dynamic]LEVEL_Room_Connection, 0, 4)
    //defer delete(rand_enum_choice)

    // maintain a connected and unconnected bucket, and a filled bucket
    // randomly select from the unconnected bucket and attach it to
    // a randomly selected connected bucket item
    // once a connected block has all of its directions connected to, 
    // put it into the filled bucket
    filled_blocks := make([dynamic]TEMP_Block_Connection, 0, LEVEL_WORLD_BLOCKS)
    connected_blocks := make([dynamic]TEMP_Block_Connection, 0, LEVEL_WORLD_BLOCKS)
    unconnected_blocks := make([dynamic]TEMP_Block_Connection, 0, LEVEL_WORLD_BLOCKS)

    defer delete(filled_blocks)
    defer delete(connected_blocks)
    defer delete(unconnected_blocks)

    for i in 0..<LEVEL_WORLD_BLOCKS {
        // times 9 because each block has 9 rooms
        r_world_idx := cast(LEVEL_Room_World_Index) (i * 9)
        b_con := TEMP_Block_Connection{r_world_idx, {}}

        // if the room viewed is passive, connect the boss room randomly
        if !world.rooms[r_world_idx].aggression {
            boss_axis := rand.choice_enum(LEVEL_Room_Connection)

            // create connection for block room to boss
            from_idx := r_world_idx + LEVEL_block_world_idx_offset_by_dir(boss_axis)
            to_idx := cast(LEVEL_Room_World_Index) (total_room_count)
            LEVEL_apply_world_rooms_connection(world, from_idx, to_idx, boss_axis)

            LEVEL_create_world_room(world, to_idx, .Debug_L01, .Block)
            

            total_room_count += 1
        }

        if i == 0 do append(&connected_blocks, b_con)
        else do append(&unconnected_blocks, b_con)
    }

    //connections can have a length of 2, 3, or 4 rooms
    connect_len_choices: []int = {2, 3, 4}

    // append the first block to the connected bucket to start the algo
    
    block_connection: for len(unconnected_blocks) > 0 {
        // get uncon and con indicies so that removal is easier
        uncon_idx := rand.int_max(len(unconnected_blocks))
        con_idx := rand.int_max(len(connected_blocks))

        // pick the uncon and con
        uncon_pick := &unconnected_blocks[uncon_idx]
        con_pick := &connected_blocks[con_idx]

        // decide the axis to connect on
        selected_axis: LEVEL_Room_Connection = rand.choice_enum(LEVEL_Room_Connection)
        // we add the extra pick on the uncon direction connections because of the 
        // passive block being autoconnected to the boss room
        orig_axis := selected_axis
        for con_pick.connection_directions[selected_axis] || uncon_pick.connection_directions[selected_axis] {
            cycle_axis_bool := int(selected_axis) + 1
            if cycle_axis_bool >= len(con_pick.connection_directions) do cycle_axis_bool = 0
            selected_axis = cast(LEVEL_Room_Connection) cycle_axis_bool

            // this is the worst fucking case scenario, where the boss room was connected to the passive block on the
            // exact direction path that is only open to the randomly selected block, which must be connected on all other axiis
            // in this case, reset
            if orig_axis == selected_axis {
                continue block_connection
            }
        }
        // find the connection length
        connect_len := rand.choice(connect_len_choices)

        //update the connection axiis
        con_pick.connection_directions[selected_axis] = true

        // the newly connected blocks connection axis will be the opposite
        // of the already connected blocks
        uncon_selected_axis := LEVEL_opposite_room_connection(selected_axis)
        uncon_pick.connection_directions[uncon_selected_axis] = true

        //finally, we can connect the blocks

        // first, add the connectors to the con pick
        prev_idx := con_pick.idx + LEVEL_block_world_idx_offset_by_dir(selected_axis)
        for i in 0..<connect_len {
            to_idx := cast(LEVEL_Room_World_Index) (total_room_count)
            LEVEL_apply_world_rooms_connection(world, prev_idx, to_idx, selected_axis)
            
            LEVEL_create_world_room(world, to_idx, .Debug_L01, .Connector)

            prev_idx = to_idx
            total_room_count += 1
        }

        //then, attach the uncon pick to the connectors
        to_idx := uncon_pick.idx + LEVEL_block_world_idx_offset_by_dir(LEVEL_opposite_room_connection(selected_axis))
        LEVEL_apply_world_rooms_connection(world, prev_idx, to_idx, selected_axis)

        // add it to the connected bucket
        append(&connected_blocks, uncon_pick^)
        // remove the uncon pick from the uncon bucket
        unordered_remove(&unconnected_blocks, uncon_idx)
        
        // if the newly connected block is filled up, move it to the filled block bucket
        one_axis_empty := false
        for fill in con_pick.connection_directions {
            one_axis_empty |= !fill
        }
        if !one_axis_empty {
            append(&filled_blocks, con_pick^)
            unordered_remove(&connected_blocks, con_idx)
        }

    }

    

    // finally, create tails
    // tails can be between 2 and 5 rooms long, but can be less if running out of rooms
    rand_tail_len := 2 + rand.int_max(4)
    for total_room_count < LEVEL_WORLD_ROOMS {
        // select a block to add tail to
        con_idx := rand.int_max(len(connected_blocks))
        con_pick := &connected_blocks[con_idx]

        from_temp_data := con_pick^

        // select a direction for the connection
        selected_axis := rand.choice_enum(LEVEL_Room_Connection)
        for from_temp_data.connection_directions[selected_axis] {
            cycle_axis_bool := int(selected_axis) + 1
            if cycle_axis_bool >= len(con_pick.connection_directions) do cycle_axis_bool = 0
            selected_axis = cast(LEVEL_Room_Connection) cycle_axis_bool
        }

        from_w_idx := con_pick.idx + LEVEL_block_world_idx_offset_by_dir(selected_axis)

        added_tail := 0
        for added_tail < rand_tail_len && total_room_count < LEVEL_WORLD_ROOMS {
            to_w_idx := cast(LEVEL_Room_World_Index) (total_room_count)
            to_temp_data := TEMP_Block_Connection{ to_w_idx, {} }

            opp_connection_axis := LEVEL_opposite_room_connection(selected_axis)

            //update connections axiis
            from_temp_data.connection_directions[selected_axis] = true
            to_temp_data.connection_directions[opp_connection_axis] = true

            // apply connection to world
            LEVEL_apply_world_rooms_connection(world, from_w_idx, to_w_idx, selected_axis)

            //update for next loop
            added_tail += 1
            from_w_idx = to_w_idx
            from_temp_data = to_temp_data

            LEVEL_create_world_room(world, to_w_idx, .Debug_L01, .Tail)

            total_room_count += 1
        }

        rand_tail_len = 5 + rand.int_max(7)
    }
    LEVEL_write_world_visualizer(world)
}

LEVEL_log_world :: proc(world: ^LEVEL_World) {
    log.infof("start room is %v", world.start_room)

    for i in 0..<len(world.rooms) {
        room := world.rooms[i]
        if room.tag == .Debug_L00 do return
        log.infof("Room %v:", i)
        log.infof("\taggression = %v", room.aggression)
        log.infof("\twarps = %v\n", room.warps)
    }
}

LEVEL_destroy_world_D :: proc(world: ^LEVEL_World) {
    for &room in &world.rooms {
        delete(room.enemy_info)
    }

    rl.UnloadRenderTexture(world.visualizer)
}

LEVEL_write_world_visualizer :: proc(world: ^LEVEL_World) {
    start_pixel_x: i32 = LEVEL_WORLD_ROOMS / 2
    start_pixel_y: i32 = LEVEL_WORLD_ROOMS / 2

    rl.BeginTextureMode(world.visualizer)
    defer rl.EndTextureMode()

    rl.ClearBackground(WHITE_COLOR)

    cur_room := world.rooms[world.start_room]

    b_set := bit_set[0..<LEVEL_WORLD_ROOMS]{}
    b_set += {int(world.start_room)}

    LEVEL_write_world_visualizer_helper(world, cur_room, start_pixel_x, start_pixel_y, &b_set)
}

LEVEL_write_world_visualizer_helper :: proc(world: ^LEVEL_World, room: LEVEL_Room, x, y: i32, clear_bit_set: ^bit_set[0..<LEVEL_WORLD_ROOMS]) {
    c := BLACK_COLOR
    if room.type == .Connector { c = DMG_COLOR}
    else if room.type == .Tail { c = EXP_COLOR }
    else if room.aggression == false { c = HITMARKER_2_COLOR }

    rl.DrawPixel(x, y, c)

    for w, dir in room.warps {
        if w == -1 || int(w) in clear_bit_set { continue }

        clear_bit_set^ += {int(w)}
        new_room := world.rooms[w]
        new_x := x
        new_y := y
        switch dir {
        case .North:
            new_y -= 1
        case .South:
            new_y += 1
        case .West:
            new_x -= 1
        case .East:
            new_x += 1
        }

        LEVEL_write_world_visualizer_helper(world, new_room, new_x, new_y, clear_bit_set)
    }
}