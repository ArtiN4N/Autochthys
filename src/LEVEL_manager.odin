package src

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

    enemies: [dynamic]Ship,
    enemy_bullets: [dynamic]Bullet,
    ally_bullets: [dynamic]Bullet,
    exp_points: [dynamic]STATS_Experience,
    hit_markers: [dynamic]STATS_Hitmarker,
    hazards: [dynamic]LEVEL_Hazard,
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
    man.hazards = make([dynamic]LEVEL_Hazard)

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

    log.infof("Level manager destroyed")
}

LEVEL_global_manager_set_level :: proc(tag: LEVEL_Tag, warp_coord: [2]i32 = {0,0}, debug_spawn: bool = false ) {
    game := &APP_global_app.game
    man := &game.level_manager

    old_tag: LEVEL_Tag
    no_old_tag := true
    // game starts with no current level
    if man.current_level != nil {
        old_tag = man.current_level.tag
        no_old_tag = false
        log.infof("Warping from level %v", old_tag)
    }

    log.infof("Warping to level %v", tag)

    clear(&man.enemy_bullets)
    clear(&man.ally_bullets)
    clear(&man.enemies)
    clear(&man.exp_points)
    clear(&man.hit_markers)
    clear(&man.hazards)

    render_man := &APP_global_app.render_manager

    man.current_level = &man.levels[tag]

    LEVEL_populate_entities(man, game)

    spawn := warp_coord
    dir := FVECTOR_ZERO
    if debug_spawn do spawn = man.current_level.debug_spawn
    else {
        if spawn.x < 0 {
            spawn.x = LEVEL_WIDTH - 2
            dir.x = -1
        }
        if spawn.x > LEVEL_WIDTH - 1 {
            spawn.x = 1
            dir.x = 1
        }

        if spawn.y < 0 {
            spawn.y = LEVEL_HEIGHT - 2
            dir.y = 1
        }
        if spawn.y > LEVEL_HEIGHT - 1 {
            spawn.y = 1
            dir.y = -1
        }
    }

    p_pos := LEVEL_get_tile_warp_as_real_position(spawn)
    SHIP_warp(&game.player, p_pos)
    if !debug_spawn && !no_old_tag { TRANSITION_to_from_level(old_tag, dir) }

    GAME_draw_static_map_tiles(render_man, man, tag)
}

LEVEL_populate_entities :: proc(man: ^LEVEL_Manager, game: ^Game) {
    if !man.current_level.aggression do return
    // populate with enemies
    e_info := &man.current_level.enemies_info
    for e in 0..<e_info.num_enemies {
        pos := LEVEL_get_tile_warp_as_real_position(e_info.spawns[e])
        AI_add_component_to_game(game, pos, game.player.sid, e_info.ids[e])
    }

    for w in man.current_level.warps_info.warp_tos {
        hazard_pos := w

        // move hazard pos back to level bounds
        if hazard_pos.x < 0 do hazard_pos.x = 0
        if hazard_pos.x >= LEVEL_WIDTH do hazard_pos.x = LEVEL_WIDTH - 1

        if hazard_pos.y < 0 do hazard_pos.y = 0
        if hazard_pos.y >= LEVEL_HEIGHT do hazard_pos.y = LEVEL_HEIGHT - 1

        append(&man.hazards, LEVEL_Hazard{hazard_pos})
    }

    LEVEL_add_hazard_collision(man)
}

LEVEL_update_aggression :: proc(man: ^LEVEL_Manager) {
    if !man.current_level.aggression do return

    if len(man.enemies) != 0 do return

    r_man := &APP_global_app.render_manager

    man.current_level.aggression = false

    LEVEL_remove_hazard_collision(man)

    clear(&man.hazards)
    GAME_draw_static_map_tiles(r_man, man, man.current_level.tag)
}