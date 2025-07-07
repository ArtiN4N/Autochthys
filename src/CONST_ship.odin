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
    Follower,
    Debug,
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

    gun: CONST_Gun_Type,

    shoot_count: i32,

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
        gun = CONST_Gun_Type.Player,
        shoot_count = 1,
    },
    .Tracker = {
        max_hp = 20,
        collision_radius = 3,
        tip_radius = 15,
        circle_dmg_collision = false,
        lethal_body = true,
        body_damage = 10,
        ship_speed = 800,
        invincibility_time = 0,
        damaged_time = 0.5,
        xp_drop = 100,
        gun = CONST_Gun_Type.None,
    },
    .Lobber = {
        max_hp = 40,
        collision_radius = 7,
        tip_radius = 30,
        circle_dmg_collision = false,
        lethal_body = false,
        body_damage = 0,
        ship_speed = 200,
        invincibility_time = 0,
        damaged_time = 0.5,
        xp_drop = 200,
        gun = CONST_Gun_Type.Lobber,
        shoot_count = 2,
    },
    .Follower = {
        max_hp = 30,
        collision_radius = 3,
        tip_radius = 15,
        circle_dmg_collision = false,
        lethal_body = true,
        body_damage = 10,
        ship_speed = 250,
        invincibility_time = 0,
        damaged_time = 0.5,
        xp_drop = 50,
        gun = CONST_Gun_Type.None,
    },
    .Debug = {
        max_hp = 40,
        collision_radius = 7,
        tip_radius = 30,
        circle_dmg_collision = false,
        lethal_body = false,
        body_damage = 0,
        ship_speed = 200,
        invincibility_time = 0,
        damaged_time = 0.5,
        xp_drop = 200,
        gun = CONST_Gun_Type.Debug,
        shoot_count = 2,
    },
}