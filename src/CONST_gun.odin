package src

CONST_Gun_Type :: enum {
    None = 0,
    Player,
    Lobber,
    Debug
}

CONST_Gun_Stat :: struct {
    gun_dist: f32,
    gun_cooldown: f32,    
    gun_max_ammo: int,
    gun_reload_time: f32,
    
    bullet : CONST_Bullet_Type,
    bullet_function: CONST_Bullet_Function_Type,
}

@(rodata)
CONST_gun_stats: [CONST_Gun_Type]CONST_Gun_Stat = {
    .None = {
        gun_dist = 5,
        gun_cooldown = 0.1,
        gun_max_ammo = 12,
        gun_reload_time = 1.0,
        bullet = CONST_Bullet_Type.None,
    },
    .Player = {
        gun_dist = 5,
        gun_cooldown = 0.1,
        gun_max_ammo = 12,
        gun_reload_time = 1.0,
        bullet = CONST_Bullet_Type.Player,
        bullet_function = CONST_Bullet_Function_Type.Sine,
    },
    .Lobber = {
        gun_dist = 30,
        gun_cooldown = 0,
        gun_max_ammo = 1,
        gun_reload_time = 1.5,
        bullet = CONST_Bullet_Type.Lobber,
        bullet_function = CONST_Bullet_Function_Type.Straight,
    },
    .Debug = {
        gun_dist = 30,
        gun_cooldown = 0.5,
        gun_max_ammo = 1,
        gun_reload_time = 1.5,
        bullet = CONST_Bullet_Type.Lobber,
        bullet_function = CONST_Bullet_Function_Type.Straight,
    },
}