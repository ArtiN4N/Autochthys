package src

import fmt "core:fmt"

STATS_DEFAULT_PLAYER_MAX_HEALTH :: 1
STATS_DEFAULT_GUN_DAMAGE :: 1

STATS_Manager :: struct {
    // scales all stats based on progression of game
    world_scale: int,

    // direct multiplier on player and enemy stats
    boon_enemy_exp_scale: f32,
    boon_player_hp_scale: f32,
    boon_enemy_hp_scale: f32,
    boon_player_speed_scale: f32,
    // also applies to bullets
    boon_enemy_speed_scale: f32,
    boon_player_damage_scale: f32,
    boon_enemy_damage_scale: f32,

    //exp
    experience: f32,
    level: int,
}

STATS_create_manager :: proc(m: ^STATS_Manager) {
    m.world_scale = 1
    m.boon_enemy_exp_scale = 1
    m.boon_player_hp_scale = 1
    m.boon_enemy_hp_scale = 1
    m.boon_player_speed_scale = 1
    m.boon_enemy_speed_scale = 1
    m.boon_player_damage_scale = 1
    m.boon_enemy_damage_scale = 1

    //exp
    m.experience = 0
    m.level = 0
}

