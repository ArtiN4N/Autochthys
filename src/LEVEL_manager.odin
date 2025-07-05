package src

import log "core:log"
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

        man.levels[tag] = LEVEL_load_data(fpath)
        log.infof("Level %s loaded", fpath)

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
    delete(man.enemy_bullets)
    delete(man.ally_bullets)
    delete(man.enemies)
    delete(man.exp_points)
    delete(man.hit_markers)

    log.infof("Level manager destroyed")
}

LEVEL_manager_set_level :: proc(man: ^LEVEL_Manager, tag: LEVEL_Tag) {
    render_man := &APP_global_app.render_manager

    man.current_level = &man.levels[tag]
    GAME_draw_static_map_tiles(render_man, man)
}