package src

import rl "vendor:raylib"
import log "core:log"

APP_render_inventory_pull_transition :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
    t_state: APP_Transition_State,
) {
    transition_ratio := t_state.elapsed / t_state.time

    to_source := source
    to_dest := dest

    to_source.y = abs(source.height) * (1 - transition_ratio)
    to_source.height = source.height * transition_ratio

    to_dest.y = dest.height * (1 - transition_ratio)
    to_dest.height = dest.height * transition_ratio

    APP_render_game(man, source, dest, origin, rotation, tint)
    APP_render_inventory(man, to_source, to_dest, origin, rotation, tint)
}

APP_render_inventory_push_transition :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
    t_state: APP_Transition_State,
) {
    transition_ratio := t_state.elapsed / t_state.time

    to_source := source
    to_dest := dest

    to_source.y = abs(source.height) * transition_ratio
    to_source.height = source.height * (1 - transition_ratio)

    to_dest.y = dest.height * transition_ratio
    to_dest.height = dest.height * (1 - transition_ratio)

    APP_render_game(man, source, dest, origin, rotation, tint)
    APP_render_inventory(man, to_source, to_dest, origin, rotation, tint)
}