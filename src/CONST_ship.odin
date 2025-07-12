package src

import math "core:math"

SHIP_TIP_THETA :: 0
SHIP_LEFT_TAIL_THETA :: 2.6179938
SHIP_MID_TAIL_THETA :: 3.1415927
SHIP_RIGHT_TAIL_THETA :: 3.6651914

SHIP_DAMAGE_SHAKE_MAX_DIST :: 5

SHIP_TAIL_RADIUS_DIV :: 3

SHIP_PARTS_ROTATION_SPEED :: math.PI * 12

CONST_Ship_Type :: enum {
    Player = 0,
    Tracker,
    Lobber,
    Follower,
    Octopus,
}

@(rodata)
CONST_AI_ship_types: []CONST_Ship_Type = {
    .Tracker,
    .Lobber,
    .Follower,
    .Octopus,
}

CONST_Ship_Stat :: struct {
    base_max_hp: f32,
    base_dmg: f32,
    base_speed: f32,

    collision_radius, tip_radius: f32,
    circle_dmg_collision: bool,
    lethal_body: bool,
    body_damage: f32,
    
    invincibility_time: f32,
    damaged_time: f32,

    gun: CONST_Gun_Type,

    shoot_count: int,
    shoot_function: GUN_shoot_signature,
}

@(rodata)
CONST_ship_stats: [CONST_Ship_Type]CONST_Ship_Stat = {
    .Player = {
        base_max_hp = STATS_BASE_PLAYER_STAT,
        base_dmg = STATS_BASE_PLAYER_STAT,
        base_speed = STATS_BASE_PLAYER_STAT,

        collision_radius = 5,
        tip_radius = 20,
        circle_dmg_collision = true,
        lethal_body = false,
        body_damage = 0,
        
        invincibility_time = 1,
        damaged_time = 1,
        gun = CONST_Gun_Type.Player,
        shoot_count = 1,
        shoot_function = GUN_shoot_default,
    },
    .Tracker = {
        base_max_hp = 1,
        base_dmg = 10,
        base_speed = 24,

        collision_radius = 3,
        tip_radius = 15,
        circle_dmg_collision = false,
        lethal_body = true,
        body_damage = 10,
        invincibility_time = 0,
        damaged_time = 0.5,
        gun = CONST_Gun_Type.None,
        shoot_count = 0,
        shoot_function = GUN_shoot_none,
    },
    .Lobber = {
        base_max_hp = 2,
        base_dmg = 0,
        base_speed = 0,

        collision_radius = 7,
        tip_radius = 30,
        circle_dmg_collision = false,
        lethal_body = false,
        body_damage = 0,
        invincibility_time = 0,
        damaged_time = 0.5,
        gun = CONST_Gun_Type.Lobber,
        shoot_count = 2,
        shoot_function = GUN_shoot_default,
    },
    .Follower = {
        base_max_hp = 2,
        base_dmg = 10,
        base_speed = 0,

        collision_radius = 3,
        tip_radius = 15,
        circle_dmg_collision = false,
        lethal_body = true,
        body_damage = 10,
        invincibility_time = 0,
        damaged_time = 0.5,
        gun = CONST_Gun_Type.None,
        shoot_count = 0,
        shoot_function = GUN_shoot_none,
    },
    .Octopus = {
        base_max_hp = 2,
        base_dmg = 0,
        base_speed = 0,

        collision_radius = 7,
        tip_radius = 30,
        circle_dmg_collision = false,
        lethal_body = false,
        body_damage = 0,
        invincibility_time = 0,
        damaged_time = 0.5,
        gun = CONST_Gun_Type.Octopus,
        shoot_count = 3,
        shoot_function = GUN_shoot_eight,
    },
}