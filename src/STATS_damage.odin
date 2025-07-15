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

STATS_global_player_damage :: proc() -> f32 {
    man := &APP_global_app.game.stats_manager

    player_bullet_dmg: f32 = 1

    return STATS_player_damage_proc(man.boon_player_damage_scale, man.dmg + (man.dmg - STATS_BASE_PLAYER_STAT), player_bullet_dmg, man.world_scale)
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

STATS_global_enemy_damage :: proc(enemy_base_damage: f32) -> f32 {
    man := &APP_global_app.game.stats_manager

    game := &APP_global_app.game
    aggr, ok := game.current_world.rooms[game.level_manager.current_room].type.(LEVEL_Aggressive_Room)
    aggr_level := 1
    if ok {
        aggr_level = aggr.aggression_level
    }

    return STATS_enemy_damage_proc(man.boon_enemy_damage_scale, enemy_base_damage, 0, man.world_scale, aggr_level)
}