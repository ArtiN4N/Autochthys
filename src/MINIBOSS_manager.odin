package src

import rl "vendor:raylib"
import fmt "core:fmt"

MINIBOSS_State :: enum { None, Octo, Eel }

MINIBOSS_Manager :: struct {
    state: MINIBOSS_State,
    eel: [dynamic]MINIBOSS_Eel,
    octo: MINIBOSS_Octopus,
    vignette_anim_man: ANIMATION_Manager,
    vignette_set_up: bool,
    last_head_position: FVector,
}

MINIBOSS_destroy_manager_D :: proc(m: ^MINIBOSS_Manager) {
    if m.state == .Eel {
        for &e in &m.eel do MINIBOSS_destroy_eel_D(&e)
        delete(m.eel)
    }

    m.state = .None
}

MINIBOSS_Set_State :: proc(m: ^MINIBOSS_Manager, st: MINIBOSS_State) {
    MINIBOSS_destroy_manager_D(m)

    if !m.vignette_set_up {
        m.vignette_set_up = true
        anim_collections := &APP_global_app.game.animation_collections
        m.vignette_anim_man = ANIMATION_create_manager(&anim_collections[.Boss_vin])
    }

    m.state = st
    
    if st == .Eel {
        m.eel = make([dynamic]MINIBOSS_Eel)
        MINIBOSS_Add_Eel_A(m, 16)
        MINIBOSS_Add_Eel_A(m, 16)
    }
    else if st == .Octo do MINIBOSS_Set_Octo(m)
}

MINIBOSS_Set_Octo :: proc(m: ^MINIBOSS_Manager) {
    fmt.printfln("Setting miniboss octo")
}

MINIBOSS_fight_update :: proc(game: ^Game) {
    GAME_update_cursor(game)

    SHIP_update_player(&game.player, game.cursor_position, &game.level_manager.ally_bullets)
    GAME_update_bullets(&game.level_manager.ally_bullets)
    STATS_update_and_check_hitmarkers(&game.level_manager.hit_markers)

    if game.miniboss_manager.state == .Eel {
        if len(game.miniboss_manager.eel) == 0 {
            STATS_global_spawn_force_exp_proc(8000, game.miniboss_manager.last_head_position)

            MINIBOSS_destroy_manager_D(&game.miniboss_manager)
            game.miniboss_manager.state = .None

            LEVEL_unlock_room(&game.level_manager)
            
            aggr_data, _ := &game.current_world.rooms[game.level_manager.current_room].type.(LEVEL_Aggressive_Room)
            aggr_data.aggression_level = 0

            GAME_draw_static_map_tiles(&APP_global_app.render_manager, &game.level_manager, .Open, true)
            SOUND_global_music_play_by_room(game.level_manager.current_room)
            return
        }

        for &e in &game.miniboss_manager.eel {
            MINIBOSS_eel_fight_update(game, &e)
            game.miniboss_manager.last_head_position = e.head.position
        }
        
    }
    else if game.miniboss_manager.state == .Octo do MINIBOSS_octo_fight_update(game)

    if game.player.hp <= 0 {
        GAME_global_player_die()
        return
    }
}

MINIBOSS_draw_entities :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    rl.BeginTextureMode(render_man.entities)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    if game.miniboss_manager.state == .Eel {
        for &e in &game.miniboss_manager.eel do MINIBOSS_eel_fight_draw(game, &e)
    }
    else if game.miniboss_manager.state == .Octo do MINIBOSS_octo_fight_draw(game)

    SHIP_draw_player(&game.player)


    for &b in &game.level_manager.ally_bullets {
        BULLET_draw_bullet(&b, true)
    }

    for &h in &game.level_manager.hit_markers {
        STATS_draw_hitmarker(&h)
    }
}

MINIBOSS_fight_draw :: proc(render_man: ^APP_Render_Manager, game: ^Game) {
    MINIBOSS_draw_entities(render_man, game)
    GAME_draw_foreground(render_man, game)

    rl.BeginBlendMode(.ALPHA_PREMULTIPLY)

    rl.BeginTextureMode(render_man.map_tiles)
    rw, rh := APP_get_global_render_size()
    draw_rect := Rect{0, 0, f32(rw), f32(rh)}

    src_frame := to_rl_rect(ANIMATION_manager_get_src_frame(&game.miniboss_manager.vignette_anim_man))

    dest_frame := to_rl_rect(ANIMATION_manager_get_dest_frame(&game.miniboss_manager.vignette_anim_man, draw_rect))
    dest_origin := ANIMATION_manager_get_dest_origin(&game.miniboss_manager.vignette_anim_man, dest_frame)

    tex_sheet := game.miniboss_manager.vignette_anim_man.collection.entity_type
    rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, 0, {255,255,255, 50})
    rl.EndTextureMode()

    rl.BeginTextureMode(render_man.entities)
    rw, rh = APP_get_global_render_size()
    draw_rect = Rect{0, 0, f32(rw), f32(rh)}

    src_frame = to_rl_rect(ANIMATION_manager_get_src_frame(&game.miniboss_manager.vignette_anim_man))

    dest_frame = to_rl_rect(ANIMATION_manager_get_dest_frame(&game.miniboss_manager.vignette_anim_man, draw_rect))
    dest_origin = ANIMATION_manager_get_dest_origin(&game.miniboss_manager.vignette_anim_man, dest_frame)

    tex_sheet = game.miniboss_manager.vignette_anim_man.collection.entity_type
    rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, 0, rl.WHITE)
    rl.EndTextureMode()

    rl.EndBlendMode()

    GAME_draw_ui(render_man, game)
}