package src

import rl "vendor:raylib"
import os "core:os"
import log "core:log"
import fmt "core:fmt"
import strconv "core:strconv"
import strings "core:strings"

Level :: struct {
    tag: LEVEL_Tag,
    collision_map: [dynamic][dynamic]bool,
    debug_spawn: [2]f32,
    enemies_info: LEVEL_enemies_info,
    warps_info: LEVEL_warps_info,
}

LEVEL_load_data_A :: proc(l: ^Level, fpath: string, tag: LEVEL_Tag) {
    l.tag = tag
    l.collision_map = make([dynamic][dynamic]bool, LEVEL_WIDTH, LEVEL_WIDTH)
    LEVEL_init_warps_info_A(&l.warps_info)
    LEVEL_create_enemies_info_A(&l.enemies_info)

    for x in 0..<LEVEL_WIDTH {
        l.collision_map[x] = make([dynamic]bool, LEVEL_HEIGHT, LEVEL_HEIGHT)
    }

    data, ok := os.read_entire_file(fpath)
	if !ok {
        log.fatalf("Could not load level from file %s", fpath)
		panic("FATAL: check log for more info")
	}
	defer delete(data)

    str_data := string(data)
    lines := strings.split_lines(str_data)
    defer delete(lines)

    read_line := 0

    // the first LEVEL_HEIGHT lines contain LEVEL_WIDTH characters
    // # means a wall, . means air

    // some characters wont be # or . but instead a number. when this occurs we stop iterating,
    // find all contiguous numerical characters, and read its number
    // if this character is on the edge of the map, it will register as a warp,
    // and will connect to the level that the number specifies
	for y in 0..<LEVEL_HEIGHT {
        // we use a variable loop end because warps can be multiple digits
        x := 0
        real_x := 0
		for real_x < LEVEL_WIDTH {
            collision := false
            c := lines[read_line + y][x]

            if c == '#' do collision = true
            l.collision_map[real_x][y] = collision

            // simply, warps are not possible in the middle of the level
            // saves some pain for a frankly silly sounding feature
            if x > 0 && x < LEVEL_WIDTH - 1 && y > 0 && y < LEVEL_WIDTH - 1 {
                x += 1
                real_x += 1
                continue
            }

            // numerical ascii characters range from 0x30 to 0x39
            if c >= 0x30 && c <= 0x39 {
                // find the max character that can be read
                line_limit := len(lines[read_line + y])
                // this is raw string data. null terminated, but space for a possible 2nd digit
                read_number: [3]u8 = { lines[read_line + y][x], 0x00, 0x00 }

                search_x := 1
                search_max := 1
                for x + search_x < line_limit && search_x <= search_max {
                    check_char := lines[read_line + y][x + 1]
                    if check_char == '.' || check_char == '#' {
                        // no seperator, no extra digit
                        search_x += 1
                    } else if check_char >= 0x30 && check_char <= 0x39 {
                        // extra digit
                        read_number[1] = check_char
                        x += 1

                        // need to check again for seperator
                        search_max += 1
                        search_x += 1
                    } else {
                        // seperator
                        x += 1
                        search_x += 1
                    }
                }

                // this proc will handle the excess null terminator character if needed
                number_string := UTIL_string_from_char_data(read_number[:])
                warp_number := strconv.atoi(number_string)

                // now, lets find out what world were in based on the level tag
                // first, get the numerical enum value of the levels tag
                current_tag_by_int := int(l.tag) 

                level_warp_offset := 0

                // then, we linear search the read-only array containing the world offsets within the level tag enum
                inner: for i in 0..<len(LEVEL_tag_offsets_by_world) {
                    // if the current levels tag is less than the offset of the world were looking at,
                    // that means that the current level is in the world before the world were looking at
                    if current_tag_by_int < LEVEL_tag_offsets_by_world[i] do break inner

                    // otherwise, update the offset
                    level_warp_offset = LEVEL_tag_offsets_by_world[i]
                }

                // now, we need to move the warp outside the regular level bounds
                // for more seamless transitions
                // we just find which of the 4 walls the warp is on, and move the warp out of bounds accordingly
                tile_vec: [2]i32 = {i32(real_x), i32(y)}
                if real_x == 0 do tile_vec.x -= 1
                if real_x == LEVEL_WIDTH - 1 do tile_vec.x += 1

                if y == 0 do tile_vec.y -= 1
                if y == LEVEL_HEIGHT - 1 do tile_vec.y += 1

                //finally, we can add the warp to the warp info
                warp_tag := LEVEL_Tag(level_warp_offset + warp_number)
                l.warps_info.warp_tos[tile_vec] = warp_tag
            }
            x += 1
            real_x += 1
        }
	}

    // read debug spawn
    read_line = 16
    debug_coords := strings.split(lines[read_line], ",")
    defer delete(debug_coords)

    l.debug_spawn = {
        f32(strconv.atof(debug_coords[0])),
        f32(strconv.atof(debug_coords[1]))
    }

    // NOTE: REMOVE THIS USELESS NOW
    // read aggression level (1 for aggresive)
    read_line = 17
    // REMOVE THIS REMOVE THIS

    // read number of enemies
    read_line = 18

    n_enemies := strconv.atoi(lines[read_line])
    LEVEL_init_enemies_info(&l.enemies_info, n_enemies)

    read_line = 19
    for e in 0..<n_enemies {
        e_data := strings.split(lines[read_line + e], ",")
        defer delete(e_data)

        // read enemy id
        append(&l.enemies_info.ids, CONST_Ship_Type(strconv.atoi(e_data[0])))
        // read enemy tile spawn
        e_spawn := [2]f32{
            f32(strconv.atof(e_data[1])),
            f32(strconv.atof(e_data[2])),
        }

        append(&l.enemies_info.spawns, e_spawn)
    }
}

LEVEL_destroy_data_D :: proc(l: ^Level) {
    for x in 0..<LEVEL_WIDTH {
        delete(l.collision_map[x])
    }
    delete(l.collision_map)
    LEVEL_destroy_enemies_info_D(&l.enemies_info)

    LEVEL_destroy_warps_info_D(&l.warps_info)
}

LEVEL_draw :: proc(l: ^Level, l_man: ^LEVEL_Manager, force_draw_no_aggression: bool = false) {
    for x in 0..<LEVEL_WIDTH {
        for y in 0..<LEVEL_HEIGHT {
            r := LEVEL_get_rect_from_coords(i32(x), i32(y))
            col := LEVEL_TILE_AIR_COLOR
            if l.collision_map[x][y] { col = LEVEL_TILE_WALL_COLOR }
            rl.DrawRectangleRec(to_rl_rect(r), col)
        }
    }

    if force_draw_no_aggression do return

    for dir in l_man.hazards {
        tile_1, tile_2 := LEVEL_get_hazard_tiles(dir)
        r1 := LEVEL_get_rect_from_coords(i32(tile_1.x), i32(tile_1.y))
        r2 := LEVEL_get_rect_from_coords(i32(tile_2.x), i32(tile_2.y))
        col := DMG_COLOR
        rl.DrawRectangleRec(to_rl_rect(r1), col)
        rl.DrawRectangleRec(to_rl_rect(r2), col)
    }
}