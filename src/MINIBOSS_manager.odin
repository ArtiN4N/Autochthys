package src

import rl "vendor:raylib"
import fmt "core:fmt"

MINIBOSS_State :: enum { None, Octo, Eel }

MINIBOSS_Manager :: struct {
    state: MINIBOSS_State,
    eel: [dynamic]MINIBOSS_Eel,
    octo: MINIBOSS_Octopus,
}

MINIBOSS_destroy_manager_D :: proc(m: ^MINIBOSS_Manager) {
    if m.state == .Eel {
        for &e in &m.eel do MINIBOSS_destroy_eel_D(&e)
        delete(m.eel)
    }
}

MINIBOSS_Set_State :: proc(m: ^MINIBOSS_Manager, st: MINIBOSS_State) {
    MINIBOSS_destroy_manager_D(m)

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
            MINIBOSS_destroy_manager_D(&game.miniboss_manager)
            game.miniboss_manager.state = .None
            return
        }

        for &e in &game.miniboss_manager.eel do MINIBOSS_eel_fight_update(game, &e)
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
    GAME_draw_ui(render_man, game)
}