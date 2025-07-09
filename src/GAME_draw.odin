package src

import rl "vendor:raylib"
import fmt "core:fmt"

GAME_draw :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    game := &APP_global_app.game
    render_man := &APP_global_app.render_manager

    GAME_draw_items(render_man, game)
    GAME_draw_entities(render_man, game)
    GAME_draw_foreground(render_man, game)
    GAME_draw_ui(render_man, game)
}

GAME_draw_static_map_tiles :: proc(render_man: ^APP_Render_Manager, level_man: ^LEVEL_Manager, tag: LEVEL_Tag, force_no_hazards: bool = false) {
    rl.BeginTextureMode(render_man.map_tiles)
    defer rl.EndTextureMode()

    LEVEL_draw(&level_man.levels[tag], &level_man.hazards, force_no_hazards)
}
GAME_draw_items :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.items)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    for e in game.level_manager.exp_points {
        STATS_draw_exp(e)
    }
}

GAME_clear_entities :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.entities)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)
}

GAME_draw_entities :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.entities)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    for &s in &game.level_manager.enemies {
        SHIP_draw(s)
    }

    SHIP_draw_player(game.player)

    for &b in &game.level_manager.ally_bullets {
        BULLET_draw_bullet(&b, true)
    }
    for &b in &game.level_manager.enemy_bullets {
        BULLET_draw_bullet(&b)
    }

    for &h in &game.level_manager.hit_markers {
        STATS_draw_hitmarker(&h)
    }
}
GAME_draw_foreground :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.foreground)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    //avoid drawing cursor twice in inventory
    // this is a hack and it sucks but...
    app_state := APP_global_app.state
    if tstate, ok := app_state.(APP_Transition_State); ok && tstate.to == .Inventory{
        return
    }

    GAME_draw_cursor(game.cursor_position)
}
GAME_draw_ui :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.ui)
    defer rl.EndTextureMode()
    rw, rh := APP_get_global_render_size()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    GAME_draw_player_hud(&game.player, game.player_stats)

    //if LEVEL_is_room_safe(&game.level_manager, &game.test_world) {
        mmap := &game.test_world.minimap
        room := game.level_manager.current_room
        center := FVector{ mmap.draw_data.room_rects[int(room)].x, mmap.draw_data.room_rects[int(room)].y }
        
        dsize := FVector{UI_MINIMAP_WIDTH, UI_MINIMAP_HEIGHT}
        dpos := FVector{f32(rw) - UI_MINIMAP_WIDTH, 0}
        dest := rl.Rectangle{dpos.x, dpos.y, dsize.x, dsize.y}

        spos := center
        source := rl.Rectangle{spos.x, spos.y, dsize.x, -dsize.y}
        tint := rl.Color{255, 255, 255, 250}

        rl.DrawTexturePro(
            mmap.visualizer.texture,
            source, dest, FVECTOR_ZERO, 0, tint
        )
    //}
}