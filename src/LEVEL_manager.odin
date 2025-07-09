package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"
import strings "core:strings"

// Holds all level data (we may want to delay loading to when is needed, instaed it would hold the information needed to load level data)
// contains a pointer to the current level
// owns the data for all by-level things
// this means enemies, projectiles, experience, hit markers, etc
LEVEL_Manager :: struct {
    levels: [LEVEL_Tag]LEVEL_Collision,
    current_level: LEVEL_Tag,
    previous_level: LEVEL_Tag,
    current_room: LEVEL_Room_World_Index,

    enemies: [dynamic]Ship,
    enemy_bullets: [dynamic]Bullet,
    ally_bullets: [dynamic]Bullet,
    exp_points: [dynamic]STATS_Experience,
    hit_markers: [dynamic]STATS_Hitmarker,
    hazards: [LEVEL_Room_Connection]bool,

    travel_dir: LEVEL_Room_Connection,
}

LEVEL_load_manager_A :: proc(man: ^LEVEL_Manager) {
    for tag in LEVEL_Tag {
        fpath := UTIL_create_filepath_A("data/levels/", LEVEL_tag_files[tag])

        LEVEL_load_data(&man.levels[tag], fpath, tag)
        log.infof("Level wiith tag %s read", tag)

        delete(fpath)
    }

    man.enemy_bullets = make([dynamic]Bullet)
    man.ally_bullets = make([dynamic]Bullet)
    man.enemies = make([dynamic]Ship)
    man.exp_points = make([dynamic]STATS_Experience)
    man.hit_markers = make([dynamic]STATS_Hitmarker)

    log.infof("Level manager loaded")
}

LEVEL_destroy_manager_D :: proc(man: ^LEVEL_Manager) {
    delete(man.enemy_bullets)
    delete(man.ally_bullets)
    delete(man.enemies)
    delete(man.exp_points)
    delete(man.hit_markers)

    log.infof("Level manager destroyed")
}

LEVEL_manager_clear :: proc(man: ^LEVEL_Manager) {
    clear(&man.enemies)
    clear(&man.enemy_bullets)
    clear(&man.ally_bullets)
    clear(&man.exp_points)
    clear(&man.hit_markers)
}

LEVEL_manager_clean :: proc(man: ^LEVEL_Manager) {
    LEVEL_clear_hazards(man)

    // finally, we can clear all allocated data specific to the old level
    LEVEL_manager_clear(man)
}

LEVEL_manager_add_hazards_from_room :: proc(man: ^LEVEL_Manager, room: ^LEVEL_Room) {
    for dir in LEVEL_Room_Connection {
        man.hazards[dir] = room.warps[dir] != LEVEL_NULL_ROOM
    }
}

LEVEL_global_manager_enter_world :: proc() {
    game := &APP_global_app.game
    man := &game.level_manager
    world := &game.test_world
    
    man.current_room = LEVEL_WORLD_ENTRY_ROOM

    entry_tag := world.rooms[man.current_room].tag
    man.current_level = entry_tag
    LEVEL_global_manager_set_level(entry_tag, .North, LEVEL_PLAYER_BEGIN_SPAWN_POS, false)
}

LEVEL_unlock_room :: proc(man: ^LEVEL_Manager) {
    LEVEL_open_hazards(man)
}

LEVEL_assemble_room :: proc(man: ^LEVEL_Manager, world: ^LEVEL_World) {
    // get the room data
    room := LEVEL_world_get_room(world, man.current_room)

    // populate hazards array, and write them into the level
    LEVEL_manager_add_hazards_from_room(man, room)
    LEVEL_set_collision_on_hazards(man)

    // if the room is passive, then we can remove the just-added hazards,
    // effectively opening up all paths from the level
    // although killing all enemies makes the room "passive", internally it still stays a combat room
    // meaning we must do an extra check to see if the agreesion value for the room as been set to 0
    _, room_is_passive := room.type.(LEVEL_Passive_Room)
    aggression_data, room_is_aggressive := room.type.(LEVEL_Aggressive_Room)

    open_hazards := room_is_passive
    if room_is_aggressive do open_hazards |= aggression_data.aggression_level == 0
    if open_hazards do LEVEL_unlock_room(man)
}

LEVEL_global_manager_set_level :: proc(
    to_set_tag: LEVEL_Tag, warp_dir: LEVEL_Room_Connection,
    warp_coord: FVector, is_warp: bool = true
) {
    log.infof("Warping to level %v", to_set_tag)

    // access the globals
    game := &APP_global_app.game
    level_man := &game.level_manager
    render_man := &APP_global_app.render_manager
    world := &game.test_world
    trans_data := &APP_global_app.static_trans_data

    level_man.travel_dir = warp_dir
    LEVEL_manager_clean(level_man)

    TRANSITION_global_draw_game(trans_data.from_tex, level_man.current_level, false)

    level_man.previous_level = level_man.current_level
    level_man.current_level = to_set_tag

    // warp player to right spot
    p_pos := LEVEL_get_tile_warp_as_real_position(warp_coord)
    SHIP_warp(&game.player, p_pos)

    LEVEL_set_all_walls_collision(level_man)
    LEVEL_assemble_room(level_man, world)

    // do transition
    if is_warp do TRANSITION_set(.Game, .Game)

    // update relevant render textures
    //level_man.prev_map_tex = render_man.map_tiles
    GAME_draw_static_map_tiles(render_man, level_man, level_man.current_level)
}