package src

import rl "vendor:raylib"
import fmt "core:fmt"

TRANSITION_global_draw_game :: proc(rtex: rl.RenderTexture2D, level: LEVEL_Tag, entities: bool = true, force_no_hazards: bool = false) {
    game := &APP_global_app.game
    render_man := &APP_global_app.render_manager
    level_man := &game.level_manager

    GAME_draw_static_map_tiles(render_man, level_man, level, force_no_hazards)
    GAME_draw_items(render_man, game)
    if entities do GAME_draw_entities(render_man, game)
    else do GAME_clear_entities(render_man, game)
    GAME_draw_foreground(render_man, game)
    GAME_draw_ui(render_man, game)

    rl.BeginTextureMode(rtex)
    defer rl.EndTextureMode()

    screen_width, screen_height := CONFIG_get_global_screen_size()

    dest_w := f32(render_man.render_width) * render_man.render_scale
    dest_h := f32(render_man.render_height) * render_man.render_scale
    dest_off := FVector{f32(screen_width) - dest_w, f32(screen_height) - dest_h} / 2

    source       := rl.Rectangle{0, 0, f32(render_man.render_width), -f32(render_man.render_height)}
    dest         := rl.Rectangle{0, 0, dest_w, dest_h}
    origin       := rl.Vector2{0, 0}
    rotation: f32 = 0
    tint         := rl.WHITE
    APP_render_game(render_man, source, dest, origin, rotation, tint)
}

TRANSITION_global_draw_inventory :: proc(rtex: rl.RenderTexture2D) {
    game := &APP_global_app.game
    render_man := &APP_global_app.render_manager
    level_man := &game.level_manager

    INVENTORY_draw(render_man, game)

    rl.BeginTextureMode(rtex)
    defer rl.EndTextureMode()

    screen_width, screen_height := CONFIG_get_global_screen_size()

    dest_w := f32(render_man.render_width) * render_man.render_scale
    dest_h := f32(render_man.render_height) * render_man.render_scale
    dest_off := FVector{f32(screen_width) - dest_w, f32(screen_height) - dest_h} / 2

    source       := rl.Rectangle{0, 0, f32(render_man.render_width), -f32(render_man.render_height)}
    dest         := rl.Rectangle{0,0, dest_w, dest_h}
    origin       := rl.Vector2{0, 0}
    rotation: f32 = 0
    tint         := rl.WHITE
    APP_render_menu(render_man, source, dest, origin, rotation, tint)
}

TRANSITION_global_draw_black_menu :: proc(rtex: rl.RenderTexture2D) {
    app := &APP_global_app
    game := &app.game
    render_man := &APP_global_app.render_manager
    level_man := &game.level_manager

    rl.BeginTextureMode(render_man.menu)
    rl.ClearBackground(rl.BLACK)
    rl.EndTextureMode()

    rl.BeginTextureMode(rtex)
    defer rl.EndTextureMode()

    screen_width, screen_height := CONFIG_get_global_screen_size()

    dest_w := f32(render_man.render_width) * render_man.render_scale
    dest_h := f32(render_man.render_height) * render_man.render_scale
    dest_off := FVector{f32(screen_width) - dest_w, f32(screen_height) - dest_h} / 2

    source       := rl.Rectangle{0, 0, f32(render_man.render_width), -f32(render_man.render_height)}
    dest         := rl.Rectangle{0,0, dest_w, dest_h}
    origin       := rl.Vector2{0, 0}
    rotation: f32 = 0
    tint         := rl.WHITE
    APP_render_menu(render_man, source, dest, origin, rotation, tint)
}

TRANSITION_global_draw_intro :: proc(rtex: rl.RenderTexture2D) {
    app := &APP_global_app
    game := &app.game
    render_man := &APP_global_app.render_manager
    level_man := &game.level_manager

    INTRO_draw_transition(render_man, app)

    rl.BeginTextureMode(rtex)
    defer rl.EndTextureMode()

    screen_width, screen_height := CONFIG_get_global_screen_size()

    dest_w := f32(render_man.render_width) * render_man.render_scale
    dest_h := f32(render_man.render_height) * render_man.render_scale
    dest_off := FVector{f32(screen_width) - dest_w, f32(screen_height) - dest_h} / 2

    source       := rl.Rectangle{0, 0, f32(render_man.render_width), -f32(render_man.render_height)}
    dest         := rl.Rectangle{0,0, dest_w, dest_h}
    origin       := rl.Vector2{0, 0}
    rotation: f32 = 0
    tint         := rl.WHITE
    APP_render_menu(render_man, source, dest, origin, rotation, tint)
}

TRANSITION_global_draw_menu :: proc(rtex: rl.RenderTexture2D) {
    app := &APP_global_app
    game := &app.game
    render_man := &APP_global_app.render_manager
    level_man := &game.level_manager

    MENU_state_draw(render_man, app)

    rl.BeginTextureMode(rtex)
    defer rl.EndTextureMode()

    screen_width, screen_height := CONFIG_get_global_screen_size()

    dest_w := f32(render_man.render_width) * render_man.render_scale
    dest_h := f32(render_man.render_height) * render_man.render_scale
    dest_off := FVector{f32(screen_width) - dest_w, f32(screen_height) - dest_h} / 2

    source       := rl.Rectangle{0, 0, f32(render_man.render_width), -f32(render_man.render_height)}
    dest         := rl.Rectangle{0,0, dest_w, dest_h}
    origin       := rl.Vector2{0, 0}
    rotation: f32 = 0
    tint         := rl.WHITE
    APP_render_menu(render_man, source, dest, origin, rotation, tint)
}