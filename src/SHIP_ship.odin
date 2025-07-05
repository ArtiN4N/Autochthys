package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"

// should have a global array of ship data that each ship just references
// so static data like speed or damage dont need to be stored in each ship
Ship :: struct {
    sid: int,

    hp, max_hp: f32,

    position: FVector,
    collision_radius: f32,
    rotation: f32,

    circle_dmg_collision: bool,
    lethal_body: bool,
    body_damage: f32,

    tip_theta, left_tail_theta, right_tail_theta, mid_tail_theta: f32,
    tip_radius, tail_radius: f32,

    move_dir, velocity: FVector,
    speed: f32,

    gun: SHIP_Gun,

    invincibility_elapsed, invincibility_time: f32,
    invincibility_active: bool,

    damaged_elapsed, damaged_time: f32,
    damaged_active: bool,

    xp_drop: f32,

    dead: bool,
}

SHIP_create_ship :: proc(defaults: CONST_Ship_Default, pos: FVector) -> Ship {
    s := Ship{
        sid = SHIP_assign_global_ship_id(),
        hp = defaults.max_hp,
        max_hp = defaults.max_hp,

        position = pos,
        collision_radius = defaults.collision_radius,
        rotation = 0,

        circle_dmg_collision = defaults.circle_dmg_collision,
        lethal_body = defaults.lethal_body,
        body_damage = defaults.body_damage,

        tip_radius = defaults.tip_radius,
        tail_radius = defaults.tip_radius / 3,
        tip_theta = SHIP_TIP_THETA,
        left_tail_theta = SHIP_LEFT_TAIL_THETA,
        right_tail_theta = SHIP_RIGHT_TAIL_THETA,
        mid_tail_theta = SHIP_MID_TAIL_THETA,

        move_dir = FVECTOR_ZERO,
        velocity = FVECTOR_ZERO,
        speed = defaults.ship_speed,

        gun = SHIP_create_gun(defaults),

        invincibility_elapsed = 0,
        invincibility_time = defaults.invincibility_time,
        invincibility_active = false,

        damaged_elapsed = 0,
        damaged_time = defaults.damaged_time,
        damaged_active = false,

        xp_drop = defaults.xp_drop,

        dead = false,
    }

    return s
}

SHIP_set_gun :: proc(s: ^Ship, g: SHIP_Gun) {
    s.gun = g
}

SHIP_warp :: proc(s: ^Ship, warp: FVector) {
    s.position = warp
}

SHIP_check_bullets_collision :: proc(s: ^Ship, blist: ^[dynamic]SHIP_Bullet) -> (hit: bool, dmg: f32) {
    s_cir := Circle{ s.position.x, s.position.y, s.collision_radius }

    i := 0
    for i < len(blist) {
        b := &blist[i]
        b_cir := Circle{ b.position.x, b.position.y, b.radius }

        collision := false
        if s.circle_dmg_collision { collision = circles_collide(s_cir, b_cir) }
        else {
            collision = SHIP_body_collides_circle(s, b_cir)
        }

        if collision {
            GAME_kill_bullet(i, blist)
            return true, b.damage
        }
        else { i += 1 }
    }
    return false, 0
}

SHIP_body_collides_circle :: proc(s: ^Ship, c: Circle) -> bool {\
    verts := SHIP_get_draw_verts(s^, s.position)
    collision := triangle_collides_circle(c, verts[0], verts[1], verts[2]) // right triangle
    collision |= triangle_collides_circle(c, verts[0], verts[3], verts[2]) // left triangle

    return collision
}

SHIP_try_take_damage :: proc(s: ^Ship, dmg: f32, hit_markers: ^[dynamic]STATS_Hitmarker) {
    if s.invincibility_active { return }

    s.hp -= dmg
    SOUND_global_fx_manager_play_tag(.Ship_Hurt)

    if s.invincibility_time > 0 { s.invincibility_active = true }
    if s.damaged_time > 0 { s.damaged_active = true }

    append(hit_markers, STATS_create_hitmarker(s.position, dmg))

    log.infof("Dealt %v dmg to ship %v", dmg, s.sid)

    if s.hp <= 0 { SHIP_kill(s) }
}

SHIP_kill :: proc(s: ^Ship) {
    s.dead = true
    SOUND_global_fx_manager_play_tag(.Ship_Die)
    log.infof("Killed ship %v", s.sid)
}

SHIP_assign_global_ship_id :: proc() -> int {
    @(static) id_counter := 0
    ret := id_counter
    id_counter += 1

    return ret
}