package src

import fmt "core:fmt"

Gun :: struct {
    dist_from_ship: f32,

    cooldown: f32,
    elapsed: f32,
    cooldown_active: bool,
    reloading_active: bool,
    shooting: bool,

    shots_fired: int,
    shoot_count: int,
    shoot_pattern: GUN_shoot_signature,

    bullet : CONST_Bullet_Type,
    bullet_function : BULLET_function_update_signature,

    max_ammo: int,
    ammo: int,
    reload_time: f32,
}

GUN_create_gun :: proc(type: CONST_Gun_Type, count: int, pattern: GUN_shoot_signature) -> Gun {
    defaults := CONST_gun_stats[type]

    return {
        dist_from_ship = defaults.gun_dist,

        cooldown = defaults.gun_cooldown,

        elapsed = defaults.gun_cooldown,
        cooldown_active = false,
        reloading_active = false,
        shooting = false,

        shoot_pattern = pattern,

        shoot_count = count,
        shots_fired = 0,

        bullet = CONST_gun_stats[type].bullet,
        bullet_function = CONST_gun_stats[type].bullet_function,

        max_ammo = defaults.gun_max_ammo,
        ammo = defaults.gun_max_ammo,

        reload_time = defaults.gun_reload_time
    }
}

GUN_update_gun :: proc(g: ^Gun, ship_pos: FVector, rot: f32, blist: ^[dynamic]Bullet, ship_dmg: f32) {
    if g.reloading_active {
        if g.elapsed >= g.reload_time {
            g.elapsed = 0
            g.ammo = g.max_ammo
            g.reloading_active = false
        }
    } else if g.cooldown_active {
        if g.elapsed >= g.cooldown {
            g.elapsed = 0
            g.cooldown_active = false
        }
    }
    if g.cooldown_active || g.reloading_active { g.elapsed += dt}

    if !g.shooting {
        g.shots_fired = 0
        return 
    }

    if(g.cooldown_active) { return }

    tagss: if g.shots_fired < g.shoot_count {
        success := GUN_gun_shoot(g, ship_pos, rot, blist, ship_dmg)
        if !success do break tagss

        g.shots_fired += 1


        if g.shots_fired >= g.shoot_count {
            g.ammo -= 1
            if g.ammo <= 0 {
                g.reloading_active = true
            }
            g.shooting = false
            g.shots_fired = 0
        }
    }
}

GUN_gun_shoot :: proc(g: ^Gun, pos: FVector, rot: f32, blist: ^[dynamic]Bullet, dmg: f32) -> bool {
    if g.cooldown_active || g.reloading_active { return false }

    g.cooldown_active = true
    g.elapsed = 0

    g.shoot_pattern(g, pos, rot, blist, dmg)

    SOUND_global_fx_manager_play_tag(.Ship_Shoot)

    return true
}