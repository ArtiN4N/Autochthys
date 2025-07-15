package src

import log "core:log"
import fmt "core:fmt"

LEVEL_Passive_Room :: struct {}
LEVEL_Aggressive_Room :: struct {
    aggression_level: int,
    enemy_spawn: int,
}
LEVEL_Boss_Room :: struct {}
LEVEL_Mini_Boss_Room :: struct {}
LEVEL_Room_Type :: union { LEVEL_Passive_Room, LEVEL_Aggressive_Room, LEVEL_Boss_Room, LEVEL_Mini_Boss_Room }

LEVEL_Room :: struct {
    tag: LEVEL_Tag,
    warps: [LEVEL_Room_Connection]LEVEL_Room_World_Index,
    type: LEVEL_Room_Type,
    world_idx: LEVEL_Room_World_Index,
}

LEVEL_world_get_room :: proc(w: ^LEVEL_World, r: LEVEL_Room_World_Index) -> ^LEVEL_Room {
    return &w.rooms[r]
}

LEVEL_global_world_warp_to :: proc(
    dir: LEVEL_Room_Connection
) {
    man := &APP_global_app.game.level_manager
    world := &APP_global_app.game.current_world

    to_room := world.rooms[man.current_room].warps[dir]
    if to_room == LEVEL_NULL_ROOM {
        log.warnf("trying to warp to default room -1")
        return
    }

    SOUND_global_music_play_by_room(to_room)

    LEVEL_minimap_move_focus(world, to_room)

    LEVEL_global_world_set_room(to_room, dir, LEVEL_room_connection_to_warp_pos[dir])
}

LEVEL_global_world_set_room :: proc(
    room: LEVEL_Room_World_Index, dir: LEVEL_Room_Connection,
    warp_coord: FVector
) {
    log.infof("Warping to room %v", room)
    man := &APP_global_app.game.level_manager
    world := &APP_global_app.game.current_world
    man.current_room = room
    LEVEL_global_manager_set_level(world.rooms[room].tag, dir, warp_coord)
}

LEVEL_global_warp_to_spawn :: proc() {
    man := &APP_global_app.game.level_manager
    world := &APP_global_app.game.current_world

    if man.current_room == world.start_room do return

    to_room: LEVEL_Room_World_Index = world.start_room

    SOUND_global_music_play_by_room(to_room)
    LEVEL_minimap_move_focus(world, to_room)
    LEVEL_global_world_set_room(to_room, man.travel_dir, {7.5, 7.5})
}