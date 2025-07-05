package src

import rl "vendor:raylib"

Level :: struct {
    collision_map: [LEVEL_WIDTH][LEVEL_HEIGHT]bool,
}

LEVEL_draw :: proc(l: ^Level) {
    for x in 0..<LEVEL_WIDTH {
        for y in 0..<LEVEL_HEIGHT {
            r := LEVEL_get_rect_from_coords(u32(x), u32(y))
            col := LEVEL_TILE_AIR_COLOR
            if l.collision_map[x][y] { col = LEVEL_TILE_WALL_COLOR }
            rl.DrawRectangleRec(to_rl_rect(r), col)
        }
    }
}