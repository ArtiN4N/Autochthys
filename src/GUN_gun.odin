package src

Gun :: struct {
    dist_from_ship: f32,

    cooldown: f32,
    elapsed: f32,
    cooldown_active: bool,
    reloading_active: bool,
    shooting: bool,

    bullet : CONST_Bullet_Type,
    bullet_function : BULLET_Function_Type,
    function_time_scale: f32,

    max_ammo: int,
    ammo: int,
    reload_time: f32,
}

GUN_create_gun :: proc(type: CONST_Gun_Type) -> Gun {
    defaults := CONST_gun_stats[type]

    return {
        dist_from_ship = defaults.gun_dist,

        cooldown = defaults.gun_cooldown,

        elapsed = 0,
        cooldown_active = false,
        reloading_active = false,
        shooting = false,

        bullet = CONST_gun_stats[type].bullet,
        bullet_function = CONST_gun_stats[type].bullet_function,

        max_ammo = defaults.gun_max_ammo,
        ammo = defaults.gun_max_ammo,

        reload_time = defaults.gun_reload_time
    }
}

GUN_update_gun :: proc(g: ^Gun, ship_pos: FVector, rot: f32, blist: ^[dynamic]Bullet) {
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

    if !g.shooting { return }

    GUN_gun_shoot(g, ship_pos, rot, blist)
}

GUN_gun_shoot :: proc(g: ^Gun, pos: FVector, rot: f32, blist: ^[dynamic]Bullet) {
    if g.cooldown_active || g.reloading_active { return }

    g.ammo -= 1
    g.cooldown_active = true
    if g.ammo <= 0 { g.reloading_active = true }

    BULLET_spawn_bullet(g, pos, rot, blist)

    SOUND_global_fx_manager_play_tag(.Ship_Shoot)
}