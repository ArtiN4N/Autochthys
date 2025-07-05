package src

import rl "vendor:raylib"
import fmt "core:fmt"
import rand "core:math/rand"

// In general performance could be increased by combining loops
// not sure how much, and might affect state flow

GAME_update :: proc(game: ^Game) {
    GAME_update_cursor(game)

    i := 0
    for i < len(game.ai_collection) {
        ai := &game.ai_collection[i]
        delete_ai := ai.ai_proc(ai, game)
        if delete_ai {unordered_remove(&game.ai_collection, i) }
        else { i += 1 }
    }

    GAME_update_exp(&game.exp_points, game.player.position, game.level_manager.current_level)

    SHIP_update_player(&game.player, game.cursor_position, &game.ally_bullets, game.level_manager.current_level)
    GAME_update_ships(game, &game.enemies, &game.enemy_bullets)

    // gain exp
    GAME_update_exp_pickup(&game.player_stats, &game.player, &game.exp_points)

    // update bullets
    GAME_update_bullets(&game.ally_bullets, game.level_manager.current_level)
    GAME_update_bullets(&game.enemy_bullets, game.level_manager.current_level)

    // player take damage from bullets
    player_hit, player_dmg := SHIP_check_bullets_collision(&game.player, &game.enemy_bullets)
    if player_hit { SHIP_try_take_damage(&game.player, player_dmg, &game.hit_markers) }

    // enemy take damage from bullets
    GAME_check_ships_bullets_collision(&game.enemies, &game.ally_bullets, &game.hit_markers)

    // enemey take damage from player body

    // player take damage from enemy body
    GAME_check_player_ship_damaging_collision(&game.player, &game.enemies, &game.hit_markers)

    STATS_update_and_check_hitmarkers(&game.hit_markers)
}

GAME_update_exp_pickup :: proc(stats: ^STATS_Player, player: ^Ship, list: ^[dynamic]STATS_Experience) {
    i := 0
    for i < len(list) {
        e := list[i]
        e_cir := Circle{ e.position.x, e.position.y, STATS_EXP_PICKUP_SIZE }
        
        if SHIP_body_collides_circle(player, e_cir) {
            GAME_kill_exp(i, list)
            STATS_collect_exp(stats, STATS_DEFAULT_EXP_POINTS)

            SOUND_global_fx_manager_play_tag(.Player_Xp_Pickup)
        }
        else { i += 1 }
    }
}

GAME_update_exp :: proc(list: ^[dynamic]STATS_Experience, player_pos: FVector, level: ^Level) {
    i := 0
    for i < len(list) {
        e := &list[i]
        STATS_update_exp(e, player_pos, level)

        //if kill { GAME_kill_exp(i, list) }
        //else { i += 1 }
        i += 1
    }
}

GAME_kill_exp :: proc(idx: int, list: ^[dynamic]STATS_Experience) {
    unordered_remove(list, idx)
}

GAME_kill_bullet :: proc(idx: int, list: ^[dynamic]SHIP_Bullet) {
    unordered_remove(list, idx)
}

// change this to only need the exp list DUH
GAME_kill_ship :: proc(game: ^Game, idx: int, list: ^[dynamic]Ship) {
    s := list[idx]
    xp_drops := s.xp_drop / STATS_DEFAULT_EXP_POINTS
    for i in 0..<xp_drops {
        GAME_add_exp(game, STATS_create_exp(s.position, {rand.float32() - 0.5, rand.float32() - 0.5} * 300))
    }

    unordered_remove(list, idx)
}

GAME_update_bullets :: proc(blist: ^[dynamic]SHIP_Bullet, level: ^Level) {
    i := 0
    for i < len(blist) {
        b := &blist[i]
        kill := SHIP_update_bullet(b, level)

        if kill { GAME_kill_bullet(i, blist) }
        else { i += 1 }
    }
}

GAME_update_ships :: proc(game: ^Game, slist: ^[dynamic]Ship, bullet_spawn_list: ^[dynamic]SHIP_Bullet) {
    i := 0
    for i < len(slist) {
        s := &slist[i]
        SHIP_update(s, bullet_spawn_list, game.level_manager.current_level)

        if s.dead { GAME_kill_ship(game, i, slist) }
        else { i += 1 }
    }
}

GAME_check_ships_bullets_collision :: proc(slist: ^[dynamic]Ship, bullet_hit_list: ^[dynamic]SHIP_Bullet, hlist: ^[dynamic]STATS_Hitmarker) {
    i := 0
    for i < len(slist) {
        s := &slist[i]
        ship_hit, dmg := SHIP_check_bullets_collision(s, bullet_hit_list)
        if ship_hit { SHIP_try_take_damage(s, dmg, hlist) }
        else { i += 1 }
    }
}

GAME_check_player_ship_damaging_collision :: proc(p: ^Ship, slist: ^[dynamic]Ship, hlist: ^[dynamic]STATS_Hitmarker) {
    // redundant but faster
    if p.invincibility_active { return }

    p_cir := Circle{p.position.x, p.position.y, p.collision_radius}
    for &s in slist {
        if !s.lethal_body { continue }

        if p.circle_dmg_collision { 
            if !SHIP_body_collides_circle(&s, p_cir) { continue }
        }

        dmg := s.body_damage
        SHIP_try_take_damage(p, s.body_damage, hlist)
    }
}