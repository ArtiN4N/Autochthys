package src

import rl "vendor:raylib"

Level :: struct {
    collision_map: [LEVEL_WIDTH][LEVEL_HEIGHT]bool,
}

LEVEL_draw :: proc(l: ^Level) {
    for x in 0..<LEVEL_WIDTH {
        for y in 0..<LEVEL_HEIGHT {
            r := rl.Rectangle{ f32(x) * LEVEL_TILE_SIZE, f32(y) * LEVEL_TILE_SIZE, LEVEL_TILE_SIZE, LEVEL_TILE_SIZE}
            col := LEVEL_TILE_AIR_COLOR
            if l.collision_map[x][y] { col = LEVEL_TILE_WALL_COLOR }
            rl.DrawRectangleRec(r, col)
        }
    }
}