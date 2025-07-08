package src

LEVEL_Hazard :: struct {
    tile: [2]i32,
}

LEVEL_add_hazard_collision :: proc(man: ^LEVEL_Manager) {
    for h in man.hazards {
        man.current_level.collision_map[h.tile.x][h.tile.y] = true
    }
}

LEVEL_remove_hazard_collision :: proc(man: ^LEVEL_Manager) {
    for h in man.hazards {
        man.current_level.collision_map[h.tile.x][h.tile.y] = false
    }
}