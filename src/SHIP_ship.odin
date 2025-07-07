package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"

// should have a global array of ship data that each ship just references
// so static data like speed or damage dont need to be stored in each ship
Ship :: struct {
    sid: int,

    stat_type: CONST_Ship_Type,

    hp: f32,

    position: FVector,
    rotation: f32,

    move_dir, velocity: FVector,

    gun: Gun,

    invincibility_elapsed: f32,
    invincibility_active: bool,

    damaged_elapsed: f32,
    damaged_active: bool,

    dead: bool,
}

SHIP_create_ship :: proc(type: CONST_Ship_Type, pos: FVector) -> Ship {
    s := Ship{
        sid = SHIP_assign_global_ship_id(),

        stat_type = type,

        hp = CONST_ship_stats[type].max_hp,

        position = pos,
        rotation = 0,

        move_dir = FVECTOR_ZERO,
        velocity = FVECTOR_ZERO,

        gun = GUN_create_gun(CONST_ship_stats[type].gun),

        invincibility_elapsed = 0,
        invincibility_active = false,

        damaged_elapsed = 0,
        damaged_active = false,

        dead = false,
    }

    return s
}

SHIP_set_gun :: proc(s: ^Ship, g: Gun) {
    s.gun = g
}

SHIP_warp :: proc(s: ^Ship, warp: FVector) {
    s.position = warp
}

SHIP_check_bullets_collision :: proc(s: ^Ship, blist: ^[dynamic]Bullet) -> (hit: bool, dmg: f32) {
    stats := &CONST_ship_stats[s.stat_type]

    s_cir := Circle{ s.position.x, s.position.y, stats.collision_radius }

    i := 0
    for i < len(blist) {
        b := &blist[i]
        b_cir := Circle{ b.position.x, b.position.y, b.radius }

        collision := false
        if stats.circle_dmg_collision { collision = circles_collide(s_cir, b_cir) }
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

    stats := &CONST_ship_stats[s.stat_type]

    s.hp -= dmg
    SOUND_global_fx_manager_play_tag(.Ship_Hurt)

    if stats.invincibility_time > 0 { s.invincibility_active = true }
    if stats.damaged_time > 0 { s.damaged_active = true }

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