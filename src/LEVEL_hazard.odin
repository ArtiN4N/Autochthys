package src

import fmt "core:fmt"

LEVEL_get_hazard_rect :: proc(dir: LEVEL_Room_Connection) -> (r: Rect) {
    switch dir {
    case .North:
        r = LEVEL_get_rect_from_coords(7, -1)
        r.w += LEVEL_TILE_SIZE
    case .East:
        r = LEVEL_get_rect_from_coords(16, 7)
        r.h += LEVEL_TILE_SIZE
    case .South:
        r = LEVEL_get_rect_from_coords(7, 16)
        r.w += LEVEL_TILE_SIZE
    case .West:
        r = LEVEL_get_rect_from_coords(-1, 7)
        r.h += LEVEL_TILE_SIZE
    }

    return r
}

LEVEL_get_hazard_tiles :: proc(dir: LEVEL_Room_Connection) -> (a, b: [2]int) {
    switch dir {
    case .North:
        a = {7,0}
        b = {8,0}
    case .East:
        a = {15,7}
        b = {15,8}
    case .South:
        a = {7,15}
        b = {8,15}
    case .West:
        a = {0,7}
        b = {0,8}
    }

    return a,b
}

LEVEL_set_hazard_collision :: proc(man: ^LEVEL_Manager, collision: bool = true) {
    for dir in man.hazards {
        tile_1, tile_2 := LEVEL_get_hazard_tiles(dir)
        man.current_level.collision_map[tile_1.x][tile_1.y] = collision
        man.current_level.collision_map[tile_2.x][tile_2.y] = collision
    }
}

LEVEL_add_hazard_collision :: proc(man: ^LEVEL_Manager) {
    LEVEL_set_hazard_collision(man, true)
}

LEVEL_remove_hazard_collision :: proc(man: ^LEVEL_Manager) {
    LEVEL_set_hazard_collision(man, false)
}

LEVEL_reset_hazard_collision_removal :: proc(man: ^LEVEL_Manager) {
    for dir in LEVEL_Room_Connection {
        tile_1, tile_2 := LEVEL_get_hazard_tiles(dir)
        man.current_level.collision_map[tile_1.x][tile_1.y] = true
        man.current_level.collision_map[tile_2.x][tile_2.y] = true
    }
}