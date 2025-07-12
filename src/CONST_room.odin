package src

LEVEL_Room_World_Index :: distinct int
LEVEL_Room_Connection :: enum { North, East, South, West }

LEVEL_WORLD_ENTRY_ROOM :: 4
LEVEL_NULL_ROOM :: -1
LEVEL_WORLD_ROOMS :: 60

@(rodata)
LEVEL_start_block_num_enemy_spawn_choices := []int {
    3,4,5
}

LEVEL_START_BLOCK_AGGR :: 2

@(rodata)
LEVEL_connector_num_enemy_spawn_choices := []int {
    1,2,3
}

LEVEL_CONNECTOR_AGGR :: 1

@(rodata)
LEVEL_other_block_num_enemy_spawn_choices := []int {
    5,6,7
}

LEVEL_OTHER_BLOCK_AGGR :: 4

@(rodata)
LEVEL_tail_num_enemy_spawn_choices := []int {
    7,8,9
}

LEVEL_TAIL_AGGR :: 6


@(rodata)
LEVEL_room_connection_to_warp_pos: [LEVEL_Room_Connection][2]f32 = {
    .North = {7.5, 14},
    .East = {1, 7.5},
    .South = {7.5, 1},
    .West = {14, 7.5},
}

LEVEL_room_block_pattern_parser :: proc(lines: ..string) -> [9][9]u8 {
    ret: [9][9]u8
    r1 := 0
    r2 := 1
    r3 := 2
    for l in 0..<len(lines) {
        line := lines[l]
        hori_connections := l % 2 == 0

        if hori_connections {
            conn1 := line[1] == '-'
            conn2 := line[3] == '-'

            if conn1 {
                ret[r1][r2] = 1
                ret[r2][r1] = 1
            }
            if conn2 {
                ret[r2][r3] = 1
                ret[r3][r2] = 1
            }
        } else {
            conn1 := line[0] == '/'
            conn2 := line[2] == '/'
            conn3 := line[4] == '/'

            if conn1 {
                ret[r1][r1 + 3] = 1
                ret[r1 + 3][r1] = 1
            }
            if conn2 {
                ret[r2][r2 + 3] = 1
                ret[r2 + 3][r2] = 1
            }
            if conn3 {
                ret[r3][r3 + 3] = 1
                ret[r3 + 3][r3] = 1
            }

            r1 += 3
            r2 += 3
            r3 += 3
        }
    }

    return ret
}


// level rooms can be organized into blocks
// blocks describe a 3x3 pattern of rooms and how they link to one another
// block[n][x] is the link array for the xth room in the block (x / 9)
// block[n][x][y] is the link between room x and y, 1 for linked, 0 for not
LEVEL_precomputed_room_blocks: [][9][9]u8 = {
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "/ / /",
        "X-X-X",
        "/ / /",
        "X-X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X X",
        "/ / /",
        "X X-X",
        "/ / /",
        "X-X X"
    ),
    LEVEL_room_block_pattern_parser(
        "X X-X",
        "/ / /",
        "X-X-X",
        "/ / /",
        "X X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X X-X",
        "/ / /",
        "X-X-X",
        "/ / /",
        "X X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "    /",
        "X-X-X",
        "/    ",
        "X-X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "/    ",
        "X-X-X",
        "    /",
        "X-X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X X",
        "/ / /",
        "X X X",
        "/ / /",
        "X X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X X-X",
        "/ / /",
        "X X X",
        "/ / /",
        "X-X X"
    ),
    LEVEL_room_block_pattern_parser(
        "X X X",
        "/ / /",
        "X X X",
        "/ / /",
        "X-X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "/ / /",
        "X X X",
        "/ / /",
        "X X X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "/ / /",
        "X X X",
        "/ / /",
        "X-X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "/   /",
        "X-X-X",
        "/   /",
        "X-X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X X",
        "/ / /",
        "X-X-X",
        "/ / /",
        "X X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "/ /  ",
        "X-X-X",
        "  / /",
        "X-X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "/   /",
        "X-X X",
        "    /",
        "X-X-X"
    ),
    LEVEL_room_block_pattern_parser(
        "X-X-X",
        "/   /",
        "X X-X",
        "/    ",
        "X-X-X"
    )
}