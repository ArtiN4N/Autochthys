package src

SHIP_TIP_THETA :: 0
SHIP_LEFT_TAIL_THETA :: 2.6179938
SHIP_MID_TAIL_THETA :: 3.1415927
SHIP_RIGHT_TAIL_THETA :: 3.6651914

SHIP_DAMAGE_SHAKE_MAX_DIST :: 5

SHIP_TAIL_RADIUS_DIV :: 3

CONST_Ship_Type :: enum {
    Player = 0,
    Tracker,
    Lobber,
}

CONST_Ship_Stat :: struct {
    max_hp: f32,
    collision_radius, tip_radius: f32,
    circle_dmg_collision: bool,
    lethal_body: bool,
    body_damage: f32,
    ship_speed: f32,
    invincibility_time: f32,
    damaged_time: f32,

    gun_dist: f32,
    gun_cooldown: f32,
    bullet_speed: f32,
    bullet_radius: f32,
    bullet_time: f32,
    bullet_dmg: f32,
    bullet_parry: bool,
    gun_max_ammo: int,
    gun_reload_time: f32,

    xp_drop: f32,
}

@(rodata)
CONST_ship_stats: [CONST_Ship_Type]CONST_Ship_Stat = {
    .Player = {
        max_hp = 100,
        collision_radius = 5,
        tip_radius = 20,
        circle_dmg_collision = true,
        lethal_body = false,
        body_damage = 0,
        ship_speed = 400,
        invincibility_time = 1,
        damaged_time = 1,
        gun_dist = 5,
        gun_cooldown = 0.1,
        bullet_speed = 800,
        bullet_radius = 5,
        bullet_time = 5,
        bullet_dmg = 10,
        bullet_parry = false,
        gun_max_ammo = 12,
        gun_reload_time = 1.0,
    },
    .Tracker = {
        max_hp = 30,
        collision_radius = 3,
        tip_radius = 15,
        circle_dmg_collision = false,
        lethal_body = true,
        body_damage = 10,
        ship_speed = 800,
        invincibility_time = 0,
        damaged_time = 0.5,
        gun_dist = 0,
        gun_cooldown = 0,
        bullet_speed = 0,
        bullet_radius = 0,
        bullet_time = 0,
        bullet_dmg = 0,
        bullet_parry = false,
        gun_max_ammo = 0,
        gun_reload_time = 0,
        xp_drop = 100,
    },
    .Lobber = {
        max_hp = 70,
        collision_radius = 7,
        tip_radius = 30,
        circle_dmg_collision = false,
        lethal_body = false,
        body_damage = 0,
        ship_speed = 200,
        invincibility_time = 0,
        damaged_time = 0.5,
        gun_dist = 30,
        gun_cooldown = 0,
        bullet_speed = 300,
        bullet_radius = 10,
        bullet_time = 7,
        bullet_dmg = 20,
        bullet_parry = true,
        gun_max_ammo = 1,
        gun_reload_time = 1.5,
        xp_drop = 200,
    }
}