package src

import strings "core:strings"

LEVEL_Manager :: struct {
    current_level: ^Level,
    levels: [LEVEL_Tag]Level,
}

LEVEL_load_manager :: proc(man: ^LEVEL_Manager) {
    for tag in LEVEL_Tag {
        fpath := UTIL_create_filepath_A("data/levels/", LEVEL_tag_files[tag])

        man.levels[tag] = LEVEL_load_data(fpath)

        delete(fpath)
    }
}

LEVEL_manager_set_level :: proc(man: ^LEVEL_Manager, tag: LEVEL_Tag) {
    render_man := &APP_global_app.render_manager

    man.current_level = &man.levels[tag]
    GAME_draw_static_map_tiles(render_man, man)
}