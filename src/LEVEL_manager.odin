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
    enemy_bullets: [dynamic]SHIP_Bullet,
    ally_bullets: [dynamic]SHIP_Bullet,
    exp_points: [dynamic]STATS_Experience,
    hit_markers: [dynamic]STATS_Hitmarker,
}

LEVEL_load_manager_A :: proc(man: ^LEVEL_Manager) {
    for tag in LEVEL_Tag {
        fpath := UTIL_create_filepath_A("data/levels/", LEVEL_tag_files[tag])

        LEVEL_load_data_A(&man.levels[tag], fpath)
        log.infof("Level wiith tag %s loaded", tag)

        delete(fpath)
    }

    man.enemy_bullets = make([dynamic]SHIP_Bullet)
    man.ally_bullets = make([dynamic]SHIP_Bullet)
    man.enemies = make([dynamic]Ship)
    man.exp_points = make([dynamic]STATS_Experience)
    man.hit_markers = make([dynamic]STATS_Hitmarker)

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

    log.infof("Level manager destroyed")
}

LEVEL_manager_set_level :: proc(man: ^LEVEL_Manager, game: ^Game, tag: LEVEL_Tag) {
    clear(&man.enemy_bullets)
    clear(&man.ally_bullets)
    clear(&man.enemies)
    clear(&man.exp_points)
    clear(&man.hit_markers)

    render_man := &APP_global_app.render_manager

    man.current_level = &man.levels[tag]
    GAME_draw_static_map_tiles(render_man, man)

    e_info := &man.current_level.enemies_info

    for e in 0..<e_info.num_enemies {
        pos := LEVEL_get_tile_warp_as_real_position(e_info.spawns[e])
        AI_add_component_to_game(game, pos, game.player.sid, e_info.ids[e])
    }

    p_pos := LEVEL_get_tile_warp_as_real_position(man.current_level.debug_spawn)
    SHIP_warp(&game.player, p_pos)
}