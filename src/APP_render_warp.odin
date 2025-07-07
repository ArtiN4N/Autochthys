package src

import rl "vendor:raylib"
import log "core:log"

APP_render_warp_transition :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
    t_state: APP_Transition_State,
) {
    level_man := &APP_global_app.game.level_manager

    transition_ratio := t_state.elapsed / t_state.time

    from_dest := dest
    from_source := source
    to_dest := dest
    to_source := source

    if t_state.warp_dir.x == 1 {
        from_source.x = from_source.x + source.width * transition_ratio

        to_dest.x = to_dest.x + dest.width * (1 - transition_ratio)
        to_dest.width = dest.width * transition_ratio

        to_source.width = source.width * transition_ratio
    } else if t_state.warp_dir.x == -1 {
        from_source.width = source.width * (1 - transition_ratio)
        from_dest.width = dest.width * (1 - transition_ratio)
        from_dest.x = from_dest.x + dest.width * transition_ratio

        to_source.x = to_source.x + source.width * (1 - transition_ratio)
        to_source.width = source.width * transition_ratio

        to_dest.width = to_dest.width * transition_ratio
    } else if t_state.warp_dir.y == 1 {
        from_source.y = source.height * (1 - transition_ratio)
        from_source.height = source.height * (1 - transition_ratio)

        from_dest.y = dest.height * transition_ratio
        from_dest.height = dest.height * (1 - transition_ratio)

        to_source.height = source.height * transition_ratio

        to_dest.height = dest.height * transition_ratio
    } else if t_state.warp_dir.y == -1 {
        to_source.y = source.height * transition_ratio
        to_source.height = source.height * transition_ratio

        to_dest.y = dest.height * (1 - transition_ratio)
        to_dest.height = dest.height * transition_ratio

        from_source.height = source.height * (1 - transition_ratio)

        from_dest.height = dest.height * (1 - transition_ratio)
    }
    

    GAME_draw_static_map_tiles(man, level_man, t_state.level_from, true)
    APP_render_game(man, from_source, from_dest, origin, rotation, tint)

    GAME_draw_static_map_tiles(man, level_man, level_man.current_level.tag)
    APP_render_game(man, to_source, to_dest, origin, rotation, tint)
}

