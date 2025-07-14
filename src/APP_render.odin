package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"
import math "core:math"

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
    map_tiles,
    items,
    entities,
    foreground,
    ui,
    menu: rl.RenderTexture2D,

    render_width, render_height: int,
    render_ui_width, render_ui_height: int,
    render_scale: f32,
}

APP_set_render_manager_scale :: proc(man: ^APP_Render_Manager) {
    width_scale: f32 = CONFIG_DEFAULT_SCREEN_WIDTH / f32(man.render_width)
    height_scale: f32 = CONFIG_DEFAULT_SCREEN_HEIGHT / f32(man.render_height)

    man.render_scale = min(width_scale,height_scale)
}

APP_get_global_render_size :: proc() -> (width, height: int) {
    return APP_global_app.render_manager.render_width, APP_global_app.render_manager.render_height
}

APP_get_global_render_size_with_ui :: proc() -> (width, height: int) {
    return APP_global_app.render_manager.render_ui_width, APP_global_app.render_manager.render_ui_height
}

APP_load_render_manager_A :: proc(man: ^APP_Render_Manager) {
    sw, sh := CONFIG_get_global_screen_size()

    man.render_width = APP_DEFAULT_RENDER_WIDTH
    man.render_height = APP_DEFAULT_RENDER_HEIGHT

    man.render_ui_width = APP_DEFAULT_RENDER_WIDTH_WITH_UI
    man.render_ui_height = APP_DEFAULT_RENDER_HEIGHT_WITH_UI

    render_width := i32(man.render_width)
    render_height := i32(man.render_height)

    render_ui_width := i32(man.render_ui_width)
    render_ui_height := i32(man.render_ui_height)

    // transitions own two render textures for static transitions and without the need to call draw functions
    trans_data := &APP_global_app.static_trans_data
    APP_create_static_transition_data_A(trans_data, render_width, render_height)

    man.map_tiles  = rl.LoadRenderTexture(render_width, render_height)
    man.items      = rl.LoadRenderTexture(render_width, render_height)
    man.entities   = rl.LoadRenderTexture(render_width, render_height)
    man.foreground = rl.LoadRenderTexture(render_width, render_height)
    man.menu       = rl.LoadRenderTexture(render_width, render_height)

    man.ui         = rl.LoadRenderTexture(render_ui_width, render_ui_height)

    APP_set_render_manager_scale(man)

    log.infof("Application render data loaded")
}

APP_destroy_render_manager_D :: proc(man: ^APP_Render_Manager) {
    trans_data := &APP_global_app.static_trans_data
    APP_destroy_static_transition_data_A(trans_data)

    rl.UnloadRenderTexture(man.map_tiles)
    rl.UnloadRenderTexture(man.items)
    rl.UnloadRenderTexture(man.entities)
    rl.UnloadRenderTexture(man.foreground)
    rl.UnloadRenderTexture(man.ui)
    rl.UnloadRenderTexture(man.menu)

    log.infof("Application render data destroyed")
}

APP_render :: proc(man: ^APP_Render_Manager, state: APP_State) {
    screen_width, screen_height := CONFIG_get_global_screen_size()
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(BLACK_COLOR)

    // because the render is smaller than the screen, we place the render in the centre of the screen
    dest_w := f32(man.render_width) * man.render_scale
    dest_h := f32(man.render_height) * man.render_scale
    dest_off := FVector{f32(screen_width) - dest_w, f32(screen_height) - dest_h} / 2

    // we flip the height for the source rect so that the render textures are drawn correctly
    // otherwise they would be upside down
    source := rl.Rectangle{0, 0, f32(man.render_width), -f32(man.render_height)}
    dest   := rl.Rectangle{dest_off.x, dest_off.y, dest_w, dest_h}

    switch t in state {
    case APP_Game_State:
        APP_render_game(man, source, dest)
        APP_render_ui(man)
    case APP_Menu_State:
        APP_render_menu(man, source, dest)
        APP_render_ui(man)
    case APP_Inventory_State:
        from_tint := rl.WHITE
        from_tint.r /= 2
        from_tint.g /= 2
        from_tint.b /= 2

        APP_render_game(man, source, dest, FVECTOR_ZERO, 0, from_tint)
        APP_render_inventory(man, source, dest)
        APP_render_ui(man)
    case APP_Transition_State:
        APP_render_transition(man, source, dest)
    case APP_Dialouge_State:
        from_tint := rl.WHITE
        from_tint.r /= 2
        from_tint.g /= 2
        from_tint.b /= 2

        APP_render_game(man, source, dest, FVECTOR_ZERO, 0, from_tint)
        APP_render_menu(man, source, dest)
    case APP_Savepoint_State:
        from_tint := rl.WHITE
        from_tint.r /= 2
        from_tint.g /= 2
        from_tint.b /= 2

        APP_render_game(man, source, dest, FVECTOR_ZERO, 0, from_tint)

        //hacky savepoint dialouge to menu draw
        to_tint := rl.WHITE
        if t.dialouge_to_menu_elapsed != APP_SAVEPOINT_DIALOUGE_TO_MENU_TIME && !t.in_dialouge {
            to_tint.a = u8(255 * t.dialouge_to_menu_elapsed / APP_SAVEPOINT_DIALOUGE_TO_MENU_TIME)
        }
        // = 
        APP_render_menu(man, source, dest, FVECTOR_ZERO, 0, to_tint)
        APP_render_ui(man)
    case APP_Intro_State:
        APP_render_menu(man, source, dest, FVECTOR_ZERO, 0, rl.WHITE)
    case APP_Debug_State:
    }
}

APP_render_transition :: proc(
    man: ^APP_Render_Manager,
    source: rl.Rectangle,
    dest: rl.Rectangle,
    origin: rl.Vector2 = {0, 0},
    rotation: f32 = 0,
    tint: rl.Color = rl.WHITE,
) {
    trans_state, ok := &APP_global_app.state.(APP_Transition_State)
    trans_data := &APP_global_app.static_trans_data

    from_tint, to_tint := tint, tint
    from_source, to_source := source, source
    from_dest, to_dest := dest, dest

    // game to game transitions indicate a level warp, which requires animation rather than a fade transition
    if trans_state.from == .Game && trans_state.to == .Game {
        from_source, to_source, from_dest, to_dest = TRANSITION_warp_rects(trans_state, trans_data, source, dest)
    } else if trans_state.from == .Game && trans_state.to == .Inventory {
        from_source, to_source, from_dest, to_dest = TRANSITION_open_inv_rects(trans_state, trans_data, source, dest)
        from_tint = tint
        from_tint.r /= 2
        from_tint.g /= 2
        from_tint.b /= 2
    } else if trans_state.from == .Inventory && trans_state.to == .Game {
        from_source, to_source, from_dest, to_dest = TRANSITION_close_inv_rects(trans_state, trans_data, source, dest)
    } else {
        from_tint, to_tint = TRANSITION_fade_tints(trans_state)
    }

    rl.DrawTexturePro(trans_data.from_tex.texture, from_source, from_dest, origin, rotation, from_tint)
    rl.DrawTexturePro(trans_data.to_tex.texture, to_source, to_dest, origin, rotation, to_tint)

    APP_render_ui(man)
}

APP_render_inventory :: proc(
    man: ^APP_Render_Manager,
    source: rl.Rectangle,
    dest: rl.Rectangle,
    origin: rl.Vector2 = {0, 0},
    rotation: f32 = 0,
    tint: rl.Color = rl.WHITE,
) {
    // since inventory transitions also draw the game, we dont want to double draw it
    trans_data := &APP_global_app.static_trans_data

    o_tint := tint
    o_tint.r /= 2
    o_tint.g /= 2
    o_tint.b /= 2

    rl.DrawTexturePro(trans_data.from_tex.texture, source, dest, origin, rotation, o_tint)
    rl.DrawTexturePro(man.menu.texture, source, dest, origin, rotation, tint)
}

APP_render_menu :: proc(
    man: ^APP_Render_Manager,
    source: rl.Rectangle,
    dest: rl.Rectangle,
    origin: rl.Vector2 = {0, 0},
    rotation: f32 = 0,
    tint: rl.Color = rl.WHITE,
) {
    rl.DrawTexturePro(man.menu.texture, source, dest, origin, rotation, tint)
}

APP_render_game :: proc(
    man: ^APP_Render_Manager,
    source: rl.Rectangle,
    dest: rl.Rectangle,
    origin: rl.Vector2 = {0, 0},
    rotation: f32 = 0,
    tint: rl.Color = rl.WHITE,
) {
    final_tint := rl.ColorTint(tint, rl.Color{230,230, 255, 255})
    //final_tint := tint 

    rl.DrawTexturePro(man.map_tiles.texture, source, dest, origin, rotation, final_tint)
    rl.DrawTexturePro(man.items.texture, source, dest, origin, rotation, final_tint)
    rl.DrawTexturePro(man.entities.texture, source, dest, origin, rotation, final_tint)
    rl.DrawTexturePro(man.foreground.texture, source, dest, origin, rotation, final_tint)

}

APP_render_ui :: proc(
    man: ^APP_Render_Manager,
    source: rl.Rectangle = {0, 0, 0, 0},
    dest: rl.Rectangle = {0, 0, 0, 0},
    origin: rl.Vector2 = {0, 0},
    rotation: f32 = 0,
    tint: rl.Color = rl.WHITE,
) {
    source := source
    dest := dest

    sw, sh := CONFIG_get_global_screen_size()
    if source.width == 0 do source.width = f32(sw)
    if source.height == 0 do source.height = -f32(sh)

    if dest.width == 0 do dest.width = f32(sw)
    if dest.height == 0 do dest.height = f32(sh)

    rl.DrawTexturePro(man.ui.texture, source, dest, origin, rotation, tint)
}