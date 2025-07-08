package src

import rl "vendor:raylib"
import log "core:log"

// rendering is done in stages
// first is the far_background -- contains visual elements that exist behind the map
// next is map_tiles -- contains the actual map tiles
// then near_background -- displays above the map tiles but below game elements
// then items -- displays game items relevent for the player
// then entities -- displays all entities in game
// finally foreground -- displays cosmetic elements at the very top

// there is an extra ui render texture
// as well as an extra debug render texture for rendering debug information
APP_Render_Manager :: struct {
    far_background,
    map_tiles,
    near_background,
    items,
    entities,
    foreground,
    ui,
    menu,
    debug: rl.RenderTexture2D,

    render_width, render_height: i32,
    render_scale: f32,
}

APP_load_render_manager_A :: proc(man: ^APP_Render_Manager) {
    man.render_width = APP_DEFAULT_RENDER_WIDTH
    man.render_height = APP_DEFAULT_RENDER_HEIGHT

    screen_width, screen_height := CONFIG_get_global_screen_size()

    man.far_background = rl.LoadRenderTexture(man.render_width, man.render_height)
    man.map_tiles = rl.LoadRenderTexture(man.render_width, man.render_height)
    man.near_background = rl.LoadRenderTexture(man.render_width, man.render_height)
    man.items = rl.LoadRenderTexture(man.render_width, man.render_height)
    man.entities = rl.LoadRenderTexture(man.render_width, man.render_height)
    man.foreground = rl.LoadRenderTexture(man.render_width, man.render_height)

    man.menu = rl.LoadRenderTexture(man.render_width, man.render_height)
    man.ui = rl.LoadRenderTexture(screen_width, screen_height)
    man.debug = rl.LoadRenderTexture(screen_width, screen_height)

    APP_set_render_manager_scale(man)

    log.infof("Application render data loaded")
}

APP_set_render_manager_scale :: proc(man: ^APP_Render_Manager) {
    width_scale: f32 = CONFIG_DEFAULT_SCREEN_WIDTH / f32(man.render_width)
    height_scale: f32 = CONFIG_DEFAULT_SCREEN_HEIGHT / f32(man.render_height)

    if width_scale < height_scale {
        man.render_scale = width_scale
    } else {
        man.render_scale = height_scale
    }
}

APP_destroy_render_manager_D :: proc(man: ^APP_Render_Manager) {
    rl.UnloadRenderTexture(man.far_background)
    rl.UnloadRenderTexture(man.map_tiles)
    rl.UnloadRenderTexture(man.near_background)
    rl.UnloadRenderTexture(man.items)
    rl.UnloadRenderTexture(man.entities)
    rl.UnloadRenderTexture(man.foreground)

    rl.UnloadRenderTexture(man.ui)
    rl.UnloadRenderTexture(man.menu)
    rl.UnloadRenderTexture(man.debug)

    log.infof("Application render data destroyed")
}

APP_get_global_render_size :: proc() -> (width, height: i32) {
    return APP_global_app.render_manager.render_width, APP_global_app.render_manager.render_height
}

APP_render :: proc(man: ^APP_Render_Manager, state: APP_State) {
    screen_width, screen_height := CONFIG_get_global_screen_size()
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(BLACK_COLOR)

    // we flip the height for the source rect so that the render textures are drawn correctly
    // otherwise they would be upside down
    source       := rl.Rectangle{0, 0, f32(man.render_width), -f32(man.render_height)}
    dest_w := f32(man.render_width) * man.render_scale
    dest_h := f32(man.render_height) * man.render_scale
    dest         := rl.Rectangle{(f32(screen_width) - dest_w) / 2, (f32(screen_height) - dest_h) / 2, dest_w, dest_h}
    origin       := rl.Vector2{0, 0}
    rotation: f32 = 0
    tint         := rl.WHITE

    switch t in state {
    case APP_Game_State:
        APP_render_game(man, source, dest, origin, rotation, tint)
    case APP_Menu_State:
        APP_render_menu(man, source, dest, origin, rotation, tint)
    case APP_Inventory_State:
        APP_render_inventory(man, source, dest, origin, rotation, tint)
    case APP_Transition_State:
        APP_render_transition(man, source, dest, origin, rotation, tint, t)
    case APP_Debug_State:
        APP_render_debug(man, source, dest, origin, rotation, tint, t)
    }
}

APP_render_debug :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
    t_state: APP_Debug_State,
) {
    screen_width, screen_height := CONFIG_get_global_screen_size()

    switch t_state.original_state {
        case .Game:
            APP_render_game(man, source, dest, origin, rotation, tint)
        case .Menu:
            APP_render_menu(man, source, dest, origin, rotation, tint)
        case .Inventory:
            APP_render_inventory(man, source, dest, origin, rotation, tint)
    }

    dbg_source := rl.Rectangle{0, 0, f32(screen_width), -f32(screen_height)}
    dbg_dest := rl.Rectangle{0, 0, f32(screen_width), f32(screen_height)}
    rl.DrawTexturePro(
        man.debug.texture,
        dbg_source, dbg_dest, origin, rotation, tint
    )
}

APP_render_transition :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
    t_state: APP_Transition_State,
) {
    from_render := APP_render_menu
    to_render := APP_render_game

    switch t_state.from {
    case .Game:
        from_render = APP_render_game
    case .Menu:
        from_render = APP_render_menu
    case .Inventory:
        from_render = APP_render_inventory
    }

    switch t_state.to {
    case .Game:
        to_render = APP_render_game
    case .Menu:
        to_render = APP_render_menu
    case .Inventory:
        to_render = APP_render_inventory
    }

    if t_state.from == t_state.to && t_state.to == .Game && t_state.is_warp {
        APP_render_warp_transition(man, source, dest, origin, rotation, tint, t_state)
        return
    }

    if t_state.from == .Game && t_state.to == .Inventory {
        APP_render_inventory_pull_transition(man, source, dest, origin, rotation, tint, t_state)
        return
    } else if t_state.from == .Inventory && t_state.to == .Game {
        APP_render_inventory_push_transition(man, source, dest, origin, rotation, tint, t_state)
        return
    }

    begin_alpha, end_alpha: f32
    ratio: f32

    // otherwise all transitions are a simple fade in then out to black
    // we calculate how far along the transition is, then use that to determine the opacity of the fade rectangle
    if t_state.elapsed <= t_state.time / 2 {
        begin_alpha = 255
        end_alpha = 0

        ratio = t_state.elapsed / (t_state.time / 2)

        actual_alpha := f32(begin_alpha) + ratio * f32(end_alpha - begin_alpha)
        fade_color := rl.Color{u8(actual_alpha), u8(actual_alpha), u8(actual_alpha), 255}
        from_render(man, source, dest, origin, rotation, fade_color)
    } else {
        begin_alpha = 0
        end_alpha = 255

        ratio = (t_state.elapsed / (t_state.time / 2)) - 1

        actual_alpha := f32(begin_alpha) + ratio * f32(end_alpha - begin_alpha)
        fade_color := rl.Color{u8(actual_alpha), u8(actual_alpha), u8(actual_alpha), 255}
        to_render(man, source, dest, origin, rotation, fade_color)
    }
}

APP_render_inventory :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color
) {
    // since inventory transitions also draw the game, we dont want to double draw it
    if _, ok := APP_global_app.state.(APP_Transition_State); !ok {
        APP_render_game(man, source, dest, origin, rotation, tint)
    }

    c := tint
    c.a = 240

    rl.DrawTexturePro(
        man.menu.texture,
        source, dest, origin, rotation, c
    )
}

APP_render_menu :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color
) {
    rl.DrawTexturePro(
        man.menu.texture,
        source, dest, origin, rotation, tint
    )
}

APP_render_warp_transition_game_with_forced_texture :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
    forced_map_texture: rl.RenderTexture2D,
) {
    rl.DrawTexturePro(
        man.far_background.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        forced_map_texture.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.near_background.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.items.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.entities.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.foreground.texture,
        source, dest, origin, rotation, tint
    )

    screen_width, screen_height := CONFIG_get_global_screen_size()

    ui_source := rl.Rectangle{0, 0, f32(screen_width), -f32(screen_height)}
    ui_dest := rl.Rectangle{0, 0, f32(screen_width), f32(screen_height)}
    APP_render_ui(man, ui_source, ui_dest, origin, rotation, tint)
}

APP_render_game :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
) {
    rl.DrawTexturePro(
        man.far_background.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.map_tiles.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.near_background.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.items.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.entities.texture,
        source, dest, origin, rotation, tint
    )
    rl.DrawTexturePro(
        man.foreground.texture,
        source, dest, origin, rotation, tint
    )

    screen_width, screen_height := CONFIG_get_global_screen_size()

    ui_source := rl.Rectangle{0, 0, f32(screen_width), -f32(screen_height)}
    ui_dest := rl.Rectangle{0, 0, f32(screen_width), f32(screen_height)}
    APP_render_ui(man, ui_source, ui_dest, origin, rotation, tint)
}

APP_render_ui :: proc(
    man: ^APP_Render_Manager,
    source, dest: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color
) {
    rl.DrawTexturePro(
        man.ui.texture,
        source, dest, origin, rotation, tint
    )
}