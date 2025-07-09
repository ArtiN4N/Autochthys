package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import rand "core:math/rand"

LEVEL_WORLD_BLOCKS :: 4

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

// world room blocks are dense 3x3 cubes of rooms
// blocks are indexed by their top left element at relative index 0
// this ro array allows us to find the relative index in a block for specific block connections
@(rodata)
LEVEL_world_room_block_index_connection_offset_arr: [LEVEL_Room_Connection][3]LEVEL_Room_World_Index = {
    .North = {0, 1, 2},
    .East = {2, 5, 8},
    .South = {6, 7, 8},
    .West = {0, 3, 6},
}

LEVEL_world_room_block_index_connection_offset :: proc(con: LEVEL_Room_Connection) -> LEVEL_Room_World_Index {
    arr := LEVEL_world_room_block_index_connection_offset_arr[con]
    return rand.choice(arr[:])
}

LEVEL_create_world_room :: proc(
    world: ^LEVEL_World, room: LEVEL_Room_World_Index, tag: LEVEL_Tag, type: LEVEL_Room_Type,
) {
    r := &world.rooms[room]
    r.tag = tag
    r.type = type
}

// this function generates a random world
LEVEL_create_world_A :: proc(world: ^LEVEL_World) {
    world.visualizer = rl.LoadRenderTexture(LEVEL_WORLD_ROOMS, LEVEL_WORLD_ROOMS)

    overlap_set := make(map[IVector]LEVEL_Room_World_Index)
    defer delete(overlap_set)
    append_overlap_block :: proc(set: ^map[IVector]LEVEL_Room_World_Index, world_idx: LEVEL_Room_World_Index, tl: IVector) {
        r := IVector{1,0}
        d := IVector{0,1}

        set[tl] = world_idx
        set[tl+r] = world_idx + 1
        set[tl+2*r] = world_idx + 2

        set[tl + d] = world_idx + 3
        set[tl+r + d] = world_idx + 4
        set[tl+2*r + d] = world_idx + 5

        set[tl + 2*d] = world_idx + 6
        set[tl+r + 2*d] = world_idx + 7
        set[tl+2*r + 2*d] = world_idx + 8
    }

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

    // we fill all warps with the null room
    // because warp arrays use an enumerated array, they must be populated
    // we use the null room to check if a warp exists
    for i in 0..<LEVEL_WORLD_ROOMS {
        for c in LEVEL_Room_Connection {
            world.rooms[i].warps[c] = LEVEL_NULL_ROOM
        }
    }

    //first, create the blocks
    passive_assigned := false
    total_room_count := 0

    // populate overlap set with initial block
    append_overlap_block(&overlap_set, 0, IVector{-1,-1})

    for i in 0..<LEVEL_WORLD_BLOCKS {
        // try assigning the block to be passive
        passive_block_chance := rand.float32()
        is_passive := false
        if passive_block_chance <= ((f32(i)) / (LEVEL_WORLD_BLOCKS - 1)) && !passive_assigned {
            is_passive = true
            passive_assigned = true
        }

        // aggressive levels have an aggression level
        // this defines the relative difficulty of the enemy spawns
        // starting block has a lower level, farther blocks have higher
        aggression_level := 2
        if i != 0 do aggression_level = 4

        // choose a block warp pattern
        block_warp_pattern := rand.choice(LEVEL_precomputed_room_blocks)
        for j in 0..<9 {
            // create each room
            room_idx := cast(LEVEL_Room_World_Index) total_room_count
            // the starting room in the starting block is always passive
            if i == 0 && j == 4 {
                LEVEL_create_world_room(world, room_idx, LEVEL_DEFAULT, LEVEL_Passive_Room{})
                world.start_room = room_idx
            } else {
                r_type: LEVEL_Room_Type
                if is_passive do r_type = LEVEL_Passive_Room{}
                else do r_type = LEVEL_Aggressive_Room{ aggression_level }
                LEVEL_create_world_room(world, room_idx, LEVEL_DEFAULT, r_type)
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
        overlap_coord: IVector,
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

        b_con_ov := IVector{0,0}
        if i == 0 do b_con_ov = {-1,-1}
        b_con := TEMP_Block_Connection{r_world_idx, {}, b_con_ov}

        // if the room viewed is passive, connect the boss room randomly
        // remember that blocks are indexed by their top left
        // which means that it wont check the middle room, which has a possiblity of being passive
        // even if the block isnt
        /*if _, ok := world.rooms[r_world_idx].type.(LEVEL_Passive_Room); ok {
            boss_axis := rand.choice_enum(LEVEL_Room_Connection)

            // create connection for block room to boss
            from_idx := r_world_idx + LEVEL_world_room_block_index_connection_offset(boss_axis)
            to_idx := cast(LEVEL_Room_World_Index) (total_room_count)
            LEVEL_apply_world_rooms_connection(world, from_idx, to_idx, boss_axis)

            r_type := LEVEL_Boss_Room{}
            LEVEL_create_world_room(world, to_idx, .Debug_L01, r_type)
            
            b_con.connection_directions[boss_axis] = true

            total_room_count += 1
        }*/

        if i == 0 do append(&connected_blocks, b_con)
        else do append(&unconnected_blocks, b_con)
    }

    //connections can have a length of 2, or 3 rooms
    connect_len_choices: []int = {2, 3}

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
        for con_pick.connection_directions[selected_axis] || uncon_pick.connection_directions[LEVEL_opposite_room_connection(selected_axis)] {
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
        connect_len := 2//rand.choice(connect_len_choices)

        //update the connection axiis
        con_pick.connection_directions[selected_axis] = true

        // the newly connected blocks connection axis will be the opposite
        // of the already connected blocks
        uncon_selected_axis := LEVEL_opposite_room_connection(selected_axis)
        uncon_pick.connection_directions[uncon_selected_axis] = true

        //finally, we can connect the blocks

        // first, add the connectors to the con pick
        conn_off := LEVEL_world_room_block_index_connection_offset(selected_axis)
        prev_idx := con_pick.idx + conn_off

        // get the blocks overlap vector
        prev_overlap_vec := con_pick.overlap_coord
        // update the "prev" overlap vector to be the right room based on which connection offset we use
        switch conn_off {
        case 1:
            prev_overlap_vec.x += 1
        case 2:
            prev_overlap_vec.x += 2
        case 3:
            prev_overlap_vec.y += 1
        case 5:
            prev_overlap_vec.x += 2
            prev_overlap_vec.y += 1
        case 6:
            prev_overlap_vec.y += 2
        case 7:
            prev_overlap_vec.x += 1
            prev_overlap_vec.y += 2
        case 8:
            prev_overlap_vec.x += 2
            prev_overlap_vec.y += 2
        case:
            prev_overlap_vec = prev_overlap_vec
        }
        // what to add to get the new overlap vec
        overlap_vec_transfer := IVector{}
        switch selected_axis {
        case .North:
            overlap_vec_transfer = {0,-1}
        case .East:
            overlap_vec_transfer = {1,0}
        case .South:
            overlap_vec_transfer = {0,1}
        case .West:
            overlap_vec_transfer = {-1,0}
        }

        for i in 0..<connect_len {
            to_idx := cast(LEVEL_Room_World_Index) (total_room_count)
            LEVEL_apply_world_rooms_connection(world, prev_idx, to_idx, selected_axis)
            
            // connectors are the least aggressive rooms
            r_type := LEVEL_Aggressive_Room{ 1 }
            LEVEL_create_world_room(world, to_idx, LEVEL_DEFAULT, r_type)

            overlap_set[prev_overlap_vec + overlap_vec_transfer] = to_idx
            prev_overlap_vec = prev_overlap_vec + overlap_vec_transfer

            prev_idx = to_idx
            total_room_count += 1
        }

        awaiting_block_overlap_vec := prev_overlap_vec + overlap_vec_transfer

        //then, attach the uncon pick to the connectors
        new_block_connection_off := LEVEL_world_room_block_index_connection_offset(LEVEL_opposite_room_connection(selected_axis))
        to_idx := uncon_pick.idx + new_block_connection_off
        LEVEL_apply_world_rooms_connection(world, prev_idx, to_idx, selected_axis)

        // now, using the knowledge of the connected block's room connection overlap vec,
        // work backwards using the connection offset to find the top left overlap vec
        new_connection_tl_overlap_vec := awaiting_block_overlap_vec
        switch new_block_connection_off {
        case 1:
            new_connection_tl_overlap_vec.x -= 1
        case 2:
            new_connection_tl_overlap_vec.x -= 2
        case 3:
            new_connection_tl_overlap_vec.y -= 1
        case 5:
            new_connection_tl_overlap_vec.x -= 2
            new_connection_tl_overlap_vec.y -= 1
        case 6:
            new_connection_tl_overlap_vec.y -= 2
        case 7:
            new_connection_tl_overlap_vec.x -= 1
            new_connection_tl_overlap_vec.y -= 2
        case 8:
            new_connection_tl_overlap_vec.x -= 2
            new_connection_tl_overlap_vec.y -= 2
        case:
            new_connection_tl_overlap_vec = awaiting_block_overlap_vec
        }
        append_overlap_block(&overlap_set, uncon_pick.idx, new_connection_tl_overlap_vec)
        // update it for the block so the next connection can continue
        uncon_pick.overlap_coord = new_connection_tl_overlap_vec
        overlap_set[new_connection_tl_overlap_vec] = to_idx

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
    rand_tail_len := 2 + rand.int_max(3)
    tail_connecting: for total_room_count < LEVEL_WORLD_ROOMS {
        // select a block to add tail to
        con_idx := rand.int_max(len(connected_blocks))
        con_pick := &connected_blocks[con_idx]

        from_temp_data := con_pick

        // select a direction for the connection
        selected_axis := rand.choice_enum(LEVEL_Room_Connection)
        orig_axis := selected_axis
        for from_temp_data.connection_directions[selected_axis] {
            cycle_axis_bool := int(selected_axis) + 1
            if cycle_axis_bool >= len(con_pick.connection_directions) do cycle_axis_bool = 0
            selected_axis = cast(LEVEL_Room_Connection) cycle_axis_bool
            
            if orig_axis == selected_axis do break tail_connecting
        }

        con_off := LEVEL_world_room_block_index_connection_offset(selected_axis)
        from_w_idx := con_pick.idx + con_off

        // overlap vec stuff
        prev_overlap_vec := con_pick.overlap_coord
        switch con_off {
        case 1:
            prev_overlap_vec.x += 1
        case 2:
            prev_overlap_vec.x += 2
        case 3:
            prev_overlap_vec.y += 1
        case 5:
            prev_overlap_vec.x += 2
            prev_overlap_vec.y += 1
        case 6:
            prev_overlap_vec.y += 2
        case 7:
            prev_overlap_vec.x += 1
            prev_overlap_vec.y += 2
        case 8:
            prev_overlap_vec.x += 2
            prev_overlap_vec.y += 2
        case:
            prev_overlap_vec = prev_overlap_vec
        }
        // what to add to get the new overlap vec
        overlap_vec_transfer := IVector{}
        switch selected_axis {
        case .North:
            overlap_vec_transfer = {0,-1}
        case .East:
            overlap_vec_transfer = {1,0}
        case .South:
            overlap_vec_transfer = {0,1}
        case .West:
            overlap_vec_transfer = {-1,0}
        }

        to_temp_data: TEMP_Block_Connection

        added_tail := 0
        add_tail: for added_tail < rand_tail_len && total_room_count < LEVEL_WORLD_ROOMS {
            defer total_room_count += 1

            to_w_idx := cast(LEVEL_Room_World_Index) (total_room_count)
            to_temp_data := TEMP_Block_Connection{ to_w_idx, {}, {}}

            opp_connection_axis := LEVEL_opposite_room_connection(selected_axis)

            // tails are the most aggressive
            r_type := LEVEL_Aggressive_Room{ 6 }

            // check if newly added room overlaps with pre-exisiting rooms
            new_overlap_vec := prev_overlap_vec + overlap_vec_transfer
            if new_overlap_vec in overlap_set {
                original_room_idx := overlap_set[new_overlap_vec]
                LEVEL_apply_world_rooms_connection(world, from_w_idx, original_room_idx, selected_axis)
                total_room_count -= 1
                break add_tail
            } else {
                // append to overlap list
                overlap_set[new_overlap_vec] = to_w_idx
                prev_overlap_vec = new_overlap_vec
            }
            
            LEVEL_create_world_room(world, to_w_idx, LEVEL_DEFAULT, r_type)

            //update connections axiis
            from_temp_data.connection_directions[selected_axis] = true
            to_temp_data.connection_directions[opp_connection_axis] = true

            // apply connection to world
            LEVEL_apply_world_rooms_connection(world, from_w_idx, to_w_idx, selected_axis)

            //update for next loop
            added_tail += 1
            from_w_idx = to_w_idx
            from_temp_data = &to_temp_data

        }

        

        rand_tail_len = 2 + rand.int_max(3)
    }
    LEVEL_write_world_visualizer(world)
}

LEVEL_log_world :: proc(world: ^LEVEL_World) {
    log.infof("start room is %v", world.start_room)

    for i in 0..<len(world.rooms) {
        room := world.rooms[i]
        if room.tag == LEVEL_DEFAULT do return
        log.infof("Room %v:", i)
        log.infof("\rtype = %v", room.type)
        log.infof("\twarps = %v\n", room.warps)
    }
}

LEVEL_destroy_world_D :: proc(world: ^LEVEL_World) {

    rl.UnloadRenderTexture(world.visualizer)
}

LEVEL_write_world_visualizer :: proc(world: ^LEVEL_World) {
    start_pixel_x := LEVEL_WORLD_ROOMS / 2
    start_pixel_y := LEVEL_WORLD_ROOMS / 2

    rl.BeginTextureMode(world.visualizer)
    defer rl.EndTextureMode()

    rl.ClearBackground(WHITE_COLOR)

    cur_room := world.rooms[world.start_room]

    b_set := bit_set[0..<LEVEL_WORLD_ROOMS]{}
    b_set += {int(world.start_room)}

    overlap_set: [LEVEL_WORLD_ROOMS]IVector
    overlap_set[0] = {start_pixel_x, start_pixel_y}

    LEVEL_write_world_visualizer_helper(world, cur_room, start_pixel_x, start_pixel_y, &b_set, &overlap_set)
}

LEVEL_write_world_visualizer_helper :: proc(
    world: ^LEVEL_World, room: LEVEL_Room, x, y: int,
    clear_bit_set: ^bit_set[0..<LEVEL_WORLD_ROOMS],
    overlap_set: ^[LEVEL_WORLD_ROOMS]IVector
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

    rl.DrawPixel(i32(x), i32(y), c)

    for crm, dir in room.warps {
        if crm == - 1 do continue
        cc := rl.Color{0, 0, 0, 20}

        cx := x
        cy := y

        switch dir {
        case .North:
            cy -= 1
        case .South:
            cy += 1
        case .West:
            cx -= 1
        case .East:
            cx += 1
        }

        rl.DrawPixel(i32(cx), i32(cy), cc)
    }


    for w, dir in room.warps {
        if w == -1 || int(w) in clear_bit_set { continue }

        clear_bit_set^ += {int(w)}

        new_room := world.rooms[w]
        new_x := x
        new_y := y
        switch dir {
        case .North:
            new_y -= 2
        case .South:
            new_y += 2
        case .West:
            new_x -= 2
        case .East:
            new_x += 2
        }

        overlap_set[int(w)] = {new_x, new_y}

        LEVEL_write_world_visualizer_helper(world, new_room, new_x, new_y, clear_bit_set, overlap_set)
    }
}