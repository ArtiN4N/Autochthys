package src

import log "core:log"

LEVEL_Room :: struct {
    tag: LEVEL_Tag,
    aggression: bool,
    enemy_info: [dynamic]LEVEL_room_enemy_info,
    warps: [LEVEL_Room_Connection]LEVEL_Room_World_Index,
}

LEVEL_world_get_room :: proc(w: ^LEVEL_World, r: LEVEL_Room_World_Index) -> ^LEVEL_Room {
    return &w.rooms[r]
}

LEVEL_global_world_warp_to :: proc(
    dir: LEVEL_Room_Connection
) {
    man := &APP_global_app.game.level_manager
    world := &APP_global_app.game.test_world

    to_room := world.rooms[man.current_room].warps[dir]
    if to_room == LEVEL_NULL_ROOM {
        log.warnf("trying to warp to default room -1")
        return
    }

    LEVEL_global_world_set_room(to_room, dir, LEVEL_room_connection_to_warp_pos[dir])
}

LEVEL_global_world_set_room :: proc(
    room: LEVEL_Room_World_Index, dir: LEVEL_Room_Connection,
    warp_coord: [2]f32 = {0, 0}, debug_spawn: bool = false
) {
    log.infof("Warping to room %v", room)
    man := &APP_global_app.game.level_manager
    world := &APP_global_app.game.test_world

    man.current_room = room
    LEVEL_global_manager_set_level(man, world, world.rooms[room].tag, dir, warp_coord, debug_spawn)
}