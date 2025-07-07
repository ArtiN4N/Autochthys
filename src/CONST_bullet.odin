package src

CONST_Bullet_Type :: enum {
    None = 0,
    Player,
    Lobber,
}

CONST_Bullet_Stat :: struct {
    bullet_speed: f32,
    bullet_radius: f32,
    bullet_time: f32,
    bullet_dmg: f32,
    bullet_parry: bool,
    bullet_function: BULLET_Function_Type,
}

@(rodata)
CONST_bullet_stats: [CONST_Bullet_Type]CONST_Bullet_Stat = {
    .None = {
        bullet_speed = 0,
        bullet_radius = 0,
        bullet_time = 0,
        bullet_dmg = 0,
        bullet_parry = false,
    },
    .Player = {
        bullet_speed = 800,
        bullet_radius = 5,
        bullet_time = 5,
        bullet_dmg = 10,
        bullet_parry = false,
        bullet_function = BULLET_Function_Type.Straight,
    },
    .Lobber = {
        bullet_speed = 300,
        bullet_radius = 10,
        bullet_time = 7,
        bullet_dmg = 20,
        bullet_parry = true,
        bullet_function = BULLET_Function_Type.Straight,
    },
}