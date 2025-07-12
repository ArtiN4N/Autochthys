package src

import fmt "core:fmt"

STATS_global_player_max_hp :: proc() -> f32 {
    man := &APP_global_app.game.stats_manager

    return man.max_hp * STATS_MHP_LEVEL_TO_VALUE_MULT * man.boon_player_hp_scale
}


STATS_scale_enemy_max_hp_by_world_scale :: proc(mhp: f32, world_scale: int) -> f32 {
    ret: f32
    switch world_scale {
    case 1:
        ret = mhp
    case 2:
        ret = mhp * 2
    case:
        fallthrough
    case 3:
        ret = mhp * 4
    }
    return ret
}


STATS_global_enemy_max_hp :: proc(base_mhp: f32, aggression: int) -> f32 {
    man := &APP_global_app.game.stats_manager

    base := (base_mhp + f32(aggression - 1) * 0.5) * STATS_MHP_LEVEL_TO_VALUE_MULT
    return STATS_scale_enemy_damage_by_world_scale(base, man.world_scale) * man.boon_enemy_hp_scale
}
