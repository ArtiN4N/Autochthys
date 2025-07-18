package src

import fmt "core:fmt"

STATS_global_player_speed :: proc() -> f32 {
    man := &APP_global_app.game.stats_manager

    return STATS_BASE_PLAYER_SPEED + (man.speed - STATS_BASE_PLAYER_STAT) * STATS_SPEED_PLAYER_LEVEL_TO_VALUE_MULT * man.boon_player_speed_scale
}

STATS_global_enemy_speed :: proc(base_speed: f32) -> f32 {
    man := &APP_global_app.game.stats_manager

    return STATS_BASE_ENEMY_SPEED + base_speed * STATS_SPEED_ENEMY_LEVEL_TO_VALUE_MULT * man.boon_enemy_speed_scale
}

STATS_global_bullet_speed :: proc(base_speed: f32) -> f32 {
    man := &APP_global_app.game.stats_manager

    return STATS_BASE_ENEMY_SPEED + base_speed * STATS_SPEED_ENEMY_LEVEL_TO_VALUE_MULT * man.boon_enemy_speed_scale
}