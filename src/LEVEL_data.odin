package src

import strings "core:strings"

LEVEL_load_data :: proc(fpath: string) -> Level {
    ret: Level
    for x in 0..<LEVEL_WIDTH {
        for y in 0..<LEVEL_HEIGHT {
            ret.collision_map[x][y] = x == 0 || y == 0 || x == LEVEL_WIDTH - 1 || y == LEVEL_HEIGHT - 1
        }
    }
    return  ret
}