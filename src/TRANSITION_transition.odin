package src

import rl "vendor:raylib"
import fmt "core:fmt"

TRANSITION_finish :: proc(app: ^App, state: APP_Transition_State) {
    trans_data := &app.static_trans_data

    switch state.to {
    case .Game:
        app.state = APP_Game_State{}
    case .Menu:
        app.state = APP_Menu_State{}
    case .Inventory:
        app.state = APP_Inventory_State{}
    case .Dialouge:
        app.state = DIALOUGE_global_generate_dialouge_state_A()
    case .Savepoint:
        app.state = SAVEPOINT_global_generate_savepoint_state_A()
    }

    rl.BeginTextureMode(trans_data.from_tex)
    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
    rl.EndTextureMode()

    rl.BeginTextureMode(trans_data.to_tex)
    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
    rl.EndTextureMode()
}

TRANSITION_update :: proc(app: ^App, state: ^APP_Transition_State) {
    if state.elapsed >= state.time {
        TRANSITION_finish(app, state^)
    }

    state.elapsed += dt
}


TRANSITION_fade_tints :: proc(state: ^APP_Transition_State) -> (from_tint, to_tint: rl.Color) {
    ratio := (state.elapsed / state.time)
    if ratio <= 0.5 {
        from_tint = 255
        to_tint.a = 0

        from_tint.r = u8( 255 * 2 * (0.5 - ratio) )
        from_tint.g = u8( 255 * 2 * (0.5 - ratio) )
        from_tint.b = u8( 255 * 2 * (0.5 - ratio) )
    } else {
        from_tint = 0
        to_tint.a = 255

        to_tint.r = u8( 255 * 2 * (ratio - 0.5) )
        to_tint.g = u8( 255 * 2 * (ratio - 0.5) )
        to_tint.b = u8( 255 * 2 * (ratio - 0.5) )
    }

    return from_tint, to_tint
}

TRANSITION_warp_rects :: proc(
    state: ^APP_Transition_State, data: ^APP_Static_Transition_Data,
    source, dest: rl.Rectangle,
) -> (
   from_source, to_source, from_dest, to_dest: rl.Rectangle
) {
    ratio := (state.elapsed / state.time)

    from_source, to_source = source, source
    from_dest, to_dest = dest, dest

    if data.warp_dir == .East {
        from_source.x = from_source.x + source.width * ratio

        to_dest.x = dest.x + dest.width * (1 - ratio)
        to_dest.width = dest.width * ratio

        to_source.width = source.width * ratio
    } else if data.warp_dir == .West {
        from_source.width = source.width * (1 - ratio)
        from_dest.width = dest.width * (1 - ratio)
        from_dest.x = dest.x + dest.width * ratio

        to_source.x = source.x + source.width * (1 - ratio)
        to_source.width = source.width * ratio

        to_dest.width = dest.width * ratio
    } else if data.warp_dir == .North {
        from_source.y = source.height * (1 - ratio)
        from_source.height = source.height * (1 - ratio)

        from_dest.y = dest.height * ratio
        from_dest.height = dest.height * (1 - ratio)

        to_source.height = source.height * ratio

        to_dest.height = dest.height * ratio
    } else if data.warp_dir == .South {
        to_source.y = source.height * ratio
        to_source.height = source.height * ratio

        to_dest.y = dest.height * (1 - ratio)
        to_dest.height = dest.height * ratio

        from_source.height = source.height * (1 - ratio)

        from_dest.height = dest.height * (1 - ratio)

        //to_source = source
        //to_dest = dest
    }

    return
}

TRANSITION_open_inv_rects :: proc(
    state: ^APP_Transition_State, data: ^APP_Static_Transition_Data,
    source, dest: rl.Rectangle,
) -> (
   from_source, to_source, from_dest, to_dest: rl.Rectangle
) {
    ratio := (state.elapsed / state.time)

    from_source, to_source = source, source
    from_dest, to_dest = dest, dest

    to_source.y = abs(source.height) * (1 - ratio)
    to_source.height = source.height * ratio

    to_dest.y = dest.height * (1 - ratio)
    to_dest.height = dest.height * ratio

    return
}

TRANSITION_close_inv_rects :: proc(
    state: ^APP_Transition_State, data: ^APP_Static_Transition_Data,
    source, dest: rl.Rectangle,
) -> (
   from_source, to_source, from_dest, to_dest: rl.Rectangle
) {
    ratio := (state.elapsed / state.time)

    from_source, to_source = source, source
    from_dest, to_dest = dest, dest

    to_source.y = abs(source.height) * ratio
    to_source.height = source.height * (1 - ratio)

    to_dest.y = dest.height * ratio
    to_dest.height = dest.height * (1 - ratio)

    return
}