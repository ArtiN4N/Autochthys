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
    points: int,

    //player stats
    max_hp: f32,
    dmg: f32,
    speed: f32,

    boon_title: cstring,
}

STATS_global_player_level_up_hp :: proc() {
    man := &APP_global_app.game.stats_manager
    if man.points <= 0 do return
    man.points -= 1
    man.max_hp += 1
    SOUND_global_fx_manager_play_tag(.Player_Levelup)
}
STATS_global_player_level_up_dmg :: proc() {
    man := &APP_global_app.game.stats_manager
    if man.points <= 0 do return
    man.points -= 1
    man.dmg += 1
    SOUND_global_fx_manager_play_tag(.Player_Levelup)
}
STATS_global_player_level_up_speed :: proc() {
    man := &APP_global_app.game.stats_manager
    if man.points <= 0 do return
    man.points -= 1
    man.speed += 1
    SOUND_global_fx_manager_play_tag(.Player_Levelup)
}

STATS_global_player_max_hp_stat :: proc() -> f32 {
    return APP_global_app.game.stats_manager.max_hp
}
STATS_global_player_dmg_stat :: proc() -> f32 {
    return APP_global_app.game.stats_manager.dmg
}
STATS_global_player_speed_stat :: proc() -> f32 {
    return APP_global_app.game.stats_manager.speed
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
    m.points = 0

    m.max_hp = STATS_BASE_PLAYER_STAT
    m.dmg = STATS_BASE_PLAYER_STAT
    m.speed = STATS_BASE_PLAYER_STAT
}

