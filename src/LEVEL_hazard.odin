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

LEVEL_set_collision_on_hazard_dir :: proc(man: ^LEVEL_Manager, dir: LEVEL_Room_Connection, set: bool = true) {
    collision := &man.levels[man.current_level]

    tile_1, tile_2 := LEVEL_get_hazard_tiles(dir)
    LEVEL_set_index_collision(collision, tile_1.x, tile_1.y, set)
    LEVEL_set_index_collision(collision, tile_2.x, tile_2.y, set)
}

LEVEL_set_all_walls_collision :: proc(man: ^LEVEL_Manager) {
    for dir in LEVEL_Room_Connection {
        LEVEL_set_collision_on_hazard_dir(man, dir, true)
    }
}

LEVEL_clear_hazards :: proc(man: ^LEVEL_Manager) {
    for dir in LEVEL_Room_Connection {
        man.hazards[dir] = false
    }
}

LEVEL_set_collision_on_hazards :: proc(man: ^LEVEL_Manager, set: bool = true) {
    for exists, dir in man.hazards {
        if !exists do continue
        LEVEL_set_collision_on_hazard_dir(man, dir, set)
    }
}

LEVEL_open_hazards :: proc(man: ^LEVEL_Manager) {
    for exists, dir in man.hazards {
        if !exists do continue
        LEVEL_set_collision_on_hazard_dir(man, dir, false)
    }
}
