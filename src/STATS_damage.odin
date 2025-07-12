package src

STATS_scale_player_damage_by_world_scale :: proc(dmg: f32, world_scale: int) -> f32 {
    ret: f32
    switch world_scale {
    case 1:
        ret = dmg
    case 2:
        ret = dmg * 2
    case:
        fallthrough
    case 3:
        ret = dmg * 5
    }
    return ret
}

STATS_player_damage_proc :: proc(multiplier, base_damage, bullet_damage: f32, wscale: int) -> f32 {
    return STATS_scale_player_damage_by_world_scale((base_damage + bullet_damage) * STATS_DMG_LEVEL_TO_VALUE_MULT, wscale) * multiplier
}

STATS_global_player_damage :: proc(player_bullet_dmg: f32) -> f32 {
    man := &APP_global_app.game.stats_manager

    return STATS_player_damage_proc(man.boon_player_damage_scale, man.dmg, player_bullet_dmg, man.world_scale)
}


STATS_scale_enemy_damage_by_world_scale :: proc(dmg: f32, world_scale: int) -> f32 {
    ret: f32
    switch world_scale {
    case 1:
        ret = dmg
    case 2:
        ret = dmg * 2
    case:
        fallthrough
    case 3:
        ret = dmg * 5
    }
    return ret
}

STATS_enemy_damage_proc :: proc(multiplier, base_damage, bullet_damage: f32, wscale: int, aggression: int) -> f32 {
    return STATS_scale_enemy_damage_by_world_scale((base_damage + bullet_damage + f32(aggression - 1)) * STATS_DMG_LEVEL_TO_VALUE_MULT, wscale) * multiplier
}

STATS_global_enemy_damage :: proc(player_base_damage, player_bullet_dmg: f32, aggression: int) -> f32 {
    man := &APP_global_app.game.stats_manager

    return STATS_enemy_damage_proc(man.boon_player_damage_scale, player_base_damage, player_bullet_dmg, man.world_scale, aggression)
}