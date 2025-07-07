package src

Gun :: struct {
    dist_from_ship: f32,

    cooldown: f32,
    elapsed: f32,
    cooldown_active: bool,
    reloading_active: bool,
    shooting: bool,

    bullet_speed: f32,
    bullet_radius: f32,
    bullet_time: f32,
    bullet_damage: f32,
    bullet_parry: bool,

    max_ammo: int,
    ammo: int,
    reload_time: f32,
}

GUN_create_gun :: proc(defaults: CONST_Ship_Stat) -> Gun {
    return {
        dist_from_ship = defaults.gun_dist,

        cooldown = defaults.gun_cooldown,

        elapsed = 0,
        cooldown_active = false,
        reloading_active = false,
        shooting = false,

        bullet_speed = defaults.bullet_speed,
        bullet_radius = defaults.bullet_radius,
        bullet_time = defaults.bullet_time,
        bullet_damage = defaults.bullet_dmg,

        max_ammo = defaults.gun_max_ammo,
        ammo = defaults.gun_max_ammo,

        reload_time = defaults.gun_reload_time
    }
}

GUN_update_gun :: proc(g: ^Gun, ship_pos: FVector, rot: f32, blist: ^[dynamic]SHIP_Bullet) {
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

    SHIP_gun_shoot(g, ship_pos, rot, blist)
}

GUN_gun_shoot :: proc(g: ^Gun, pos: FVector, rot: f32, blist: ^[dynamic]SHIP_Bullet) {
    if g.cooldown_active || g.reloading_active { return }

    g.ammo -= 1
    g.cooldown_active = true
    if g.ammo <= 0 { g.reloading_active = true }

    SHIP_spawn_bullet(g, pos, rot, blist)

    SOUND_global_fx_manager_play_tag(.Ship_Shoot)
}