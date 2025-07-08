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
    levels: [LEVEL_Tag]Level,
    current_level: ^Level,
    current_room: LEVEL_Room_World_Index,

    enemies: [dynamic]Ship,
    enemy_bullets: [dynamic]Bullet,
    ally_bullets: [dynamic]Bullet,
    exp_points: [dynamic]STATS_Experience,
    hit_markers: [dynamic]STATS_Hitmarker,
    hazards: [dynamic]LEVEL_Room_Connection,

    prev_map_tex: rl.RenderTexture2D,
}

LEVEL_load_manager_A :: proc(man: ^LEVEL_Manager) {
    for tag in LEVEL_Tag {
        fpath := UTIL_create_filepath_A("data/levels/", LEVEL_tag_files[tag])

        LEVEL_load_data_A(&man.levels[tag], fpath, tag)
        log.infof("Level wiith tag %s loaded", tag)

        delete(fpath)
    }

    man.enemy_bullets = make([dynamic]Bullet)
    man.ally_bullets = make([dynamic]Bullet)
    man.enemies = make([dynamic]Ship)
    man.exp_points = make([dynamic]STATS_Experience)
    man.hit_markers = make([dynamic]STATS_Hitmarker)
    man.hazards = make([dynamic]LEVEL_Room_Connection)

    rw, rh := APP_get_global_render_size()
    man.prev_map_tex = rl.LoadRenderTexture(rw, rh)

    log.infof("Level manager loaded")
}

LEVEL_destroy_manager_D :: proc(man: ^LEVEL_Manager) {
    for tag in LEVEL_Tag {
        LEVEL_destroy_data_D(&man.levels[tag])
        log.infof("Level with tag %v destroyed", tag)
    }

    delete(man.enemy_bullets)
    delete(man.ally_bullets)
    delete(man.enemies)
    delete(man.exp_points)
    delete(man.hit_markers)
    delete(man.hazards)

    rl.UnloadRenderTexture(man.prev_map_tex)

    log.infof("Level manager destroyed")
}

LEVEL_global_manager_set_level :: proc(
    man: ^LEVEL_Manager, world: ^LEVEL_World, tag: LEVEL_Tag, warp_dir: LEVEL_Room_Connection,
    warp_coord: [2]f32 = {1,1}, debug_spawn: bool = false
) {
    game := &APP_global_app.game

    old_tag: LEVEL_Tag
    no_old_tag := true
    // game starts with no current level
    if man.current_level != nil {
        old_tag = man.current_level.tag
        no_old_tag = false
        GAME_draw_static_map_tiles_to_rtexture(man.prev_map_tex, man, old_tag, true)
        log.infof("Warping from level %v", old_tag)
    }

    log.infof("Warping to level %v", tag)

    // clear by-level entities
    clear(&man.enemy_bullets)
    clear(&man.ally_bullets)
    clear(&man.enemies)
    clear(&man.exp_points)
    clear(&man.hit_markers)
    clear(&man.hazards)

    render_man := &APP_global_app.render_manager
    man.current_level = &man.levels[tag]
    // no need to set current room since it is set by the room caller wrapper
    room := LEVEL_world_get_room(world, man.current_room)
    LEVEL_reset_hazard_collision_removal(man)

    if room.aggression do LEVEL_populate_enemies(man, game)

    // the hack here is that levels are stored with filled in wall data
    // room connections via warps must be managed by the program
    // by adding the hazards, then removing them like if combat just ended,
    // the removal function will set the needed walls' collision values to false
    LEVEL_populate_hazards(room, man)

    LEVEL_add_hazard_collision(man)
    if !room.aggression {
        LEVEL_remove_hazard_collision(man)
        clear(&man.hazards)
    }

    // warp player to right tile
    spawn := warp_coord
    if debug_spawn do spawn = man.current_level.debug_spawn
    p_pos := LEVEL_get_tile_warp_as_real_position(spawn)
    SHIP_warp(&game.player, p_pos)

    // do transition
    if !debug_spawn && !no_old_tag { TRANSITION_to_from_level(old_tag, warp_dir, true) }

    GAME_draw_static_map_tiles(render_man, man, tag)
}

LEVEL_NULL_ROOM :: -1

LEVEL_populate_hazards :: proc(room: ^LEVEL_Room, man: ^LEVEL_Manager) {
    for dir in LEVEL_Room_Connection {
        if room.warps[dir] == LEVEL_NULL_ROOM do continue

        append(&man.hazards, dir)
    }
}

LEVEL_populate_enemies :: proc(man: ^LEVEL_Manager, game: ^Game) {
    // populate with enemies
    e_info := &man.current_level.enemies_info
    for e in 0..<e_info.num_enemies {
        pos := LEVEL_get_tile_warp_as_real_position(e_info.spawns[e])
        AI_add_component_to_game(game, pos, game.player.sid, e_info.ids[e])
    }
}

LEVEL_update_room_aggression :: proc(world: ^LEVEL_World, man: ^LEVEL_Manager) {
    room := LEVEL_world_get_room(world, man.current_room)
    if !room.aggression do return
    if len(man.enemies) != 0 do return

    r_man := &APP_global_app.render_manager

    room.aggression = false

    LEVEL_remove_hazard_collision(man)
    clear(&man.hazards)

    GAME_draw_static_map_tiles(r_man, man, man.current_level.tag)
}