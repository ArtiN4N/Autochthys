package src

import rl "vendor:raylib"
import os "core:os"
import log "core:log"
import strconv "core:strconv"
import strings "core:strings"

LEVEL_enemies_info :: struct {
    num_enemies: int,
    ids: [dynamic]CONST_Ship_Type,
    spawns: [dynamic][2]u8,
}

LEVEL_init_enemies_info_A :: proc(i: ^LEVEL_enemies_info, num: int) {
    i.num_enemies = num
    i.ids = make([dynamic]CONST_Ship_Type, num, num)
    i.spawns = make([dynamic][2]u8, num, num)
}

LEVEL_destroy_enemies_info_D :: proc(i: ^LEVEL_enemies_info) {
    delete(i.ids)
    delete(i.spawns)
}

Level :: struct {
    collision_map: [dynamic][dynamic]bool,
    debug_spawn: [2]u8,
    aggression: bool,
    enemies_info: LEVEL_enemies_info,
}

LEVEL_load_data_A :: proc(l: ^Level, fpath: string) {
    l.collision_map = make([dynamic][dynamic]bool, LEVEL_WIDTH, LEVEL_WIDTH)
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
	for y in 0..<LEVEL_HEIGHT {
		for x in 0..<LEVEL_WIDTH {
            collision := false
            c := lines[read_line + y][x]

            if c == '#' do collision = true
            l.collision_map[x][y] = collision
        }
	}

    // read debug spawn
    read_line = 16
    debug_coords := strings.split(lines[read_line], ",")
    defer delete(debug_coords)

    l.debug_spawn = {
        u8(strconv.atoi(debug_coords[0])),
        u8(strconv.atoi(debug_coords[1]))
    }

    // read aggression level (1 for aggresive)
    read_line = 17

    l.aggression = lines[read_line][0] == '1'
    if !l.aggression do return

    // read number of enemies
    read_line = 18

    n_enemies := strconv.atoi(lines[read_line])
    LEVEL_init_enemies_info_A(&l.enemies_info, n_enemies)

    read_line = 19
    for e in 0..<n_enemies {
        e_data := strings.split(lines[read_line + e], ",")
        defer delete(e_data)

        // read enemy id
        l.enemies_info.ids[e] = CONST_Ship_Type(strconv.atoi(e_data[0]))
        // read enemy tile spawn
        l.enemies_info.spawns[e][0] = u8(strconv.atoi(e_data[1]))
        l.enemies_info.spawns[e][1] = u8(strconv.atoi(e_data[2]))
    }
}

LEVEL_destroy_data_D :: proc(l: ^Level) {
    for x in 0..<LEVEL_WIDTH {
        delete(l.collision_map[x])
    }
    delete(l.collision_map)
    if l.aggression do LEVEL_destroy_enemies_info_D(&l.enemies_info)
}

LEVEL_draw :: proc(l: ^Level) {
    for x in 0..<LEVEL_WIDTH {
        for y in 0..<LEVEL_HEIGHT {
            r := LEVEL_get_rect_from_coords(i32(x), i32(y))
            col := LEVEL_TILE_AIR_COLOR
            if l.collision_map[x][y] { col = LEVEL_TILE_WALL_COLOR }
            rl.DrawRectangleRec(to_rl_rect(r), col)
        }
    }
}