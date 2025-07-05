package src

import rl "vendor:raylib"
import log "core:log"

LEVEL_add_enemy :: proc(man: ^LEVEL_Manager, e: Ship) -> (eid: int) {
    append(&man.enemies, e)
    return e.sid
}

LEVEL_add_exp :: proc(man: ^LEVEL_Manager, e: STATS_Experience) {
    append(&man.exp_points, e)
}