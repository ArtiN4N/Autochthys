package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"
import math "core:math"

// should have a global array of ship data that each ship just references
// so static data like speed or damage dont need to be stored in each ship
Ship :: struct {
    sid: int,

    stat_type: CONST_Ship_Type,

    hp: f32,
    aggr: int,

    position: FVector,
    rotation: f32,

    move_dir, velocity: FVector,

    gun: Gun,

    invincibility_elapsed: f32,
    invincibility_active: bool,

    damaged_elapsed: f32,
    damaged_active: bool,

    last_parry_attempt: f64,

    dead: bool,

    parts_rotation_delay: f32,
    parts_rotation: f32,
    body_anim_manager: ANIMATION_Manager,
    tail_anim_manager: ANIMATION_Manager,
    fin_anim_manager: ANIMATION_Manager,
    anim_type: ANIMATION_Entity_Type,
    collision_rect: Rect,
}

SHIP_create_ship :: proc(type: CONST_Ship_Type, pos: FVector, atype: ANIMATION_Entity_Type, aggr: int = 1) -> Ship {
    anim_collections := &APP_global_app.game.animation_collections

    max_hp := STATS_global_enemy_max_hp(CONST_ship_stats[type].base_max_hp, aggr)
    if type == .Player do max_hp = STATS_global_player_max_hp()

    s := Ship{
        sid = SHIP_assign_global_ship_id(),

        stat_type = type,

        hp = max_hp,
        aggr = aggr,

        position = pos,
        rotation = 0,
        parts_rotation = 0,

        move_dir = FVECTOR_ZERO,
        velocity = FVECTOR_ZERO,

        gun = GUN_create_gun(CONST_ship_stats[type].gun, CONST_ship_stats[type].shoot_count, CONST_ship_stats[type].shoot_function),

        invincibility_elapsed = 0,
        invincibility_active = false,

        damaged_elapsed = 0,
        damaged_active = false,

        last_parry_attempt = total_t,

        dead = false,

        body_anim_manager = ANIMATION_create_manager(&anim_collections[atype]),
        tail_anim_manager = ANIMATION_create_manager(&anim_collections[ANIMATION_Entity_main_to_tail[atype]]),
        fin_anim_manager = ANIMATION_create_manager(&anim_collections[ANIMATION_Entity_main_to_fin[atype]]),
        anim_type = atype,
    }

    return s
}

SHIP_set_gun :: proc(s: ^Ship, g: Gun) {
    s.gun = g
}

SHIP_warp :: proc(s: ^Ship, warp: FVector) {
    s.position = warp
}

SHIP_check_bullets_collision :: proc(s: ^Ship, blist: ^[dynamic]Bullet) -> (hit: bool, dmg: f32, bullet: ^Bullet) {
    stats := &CONST_ship_stats[s.stat_type]

    s_cir := Circle{ s.position.x, s.position.y, stats.collision_radius }
    parry_cir := Circle{ s.position.x, s.position.y, PARRY_RADIUS }

    i := 0
    for i < len(blist) {
        b := &blist[i]
        b_cir := Circle{ b.position.x, b.position.y, CONST_bullet_stats[b.type].bullet_radius }

        collision := false
        parry_collision := false

        //Parrying
        if(circles_collide(parry_cir, b_cir)){
            if(BULLET_parry_success(b, s)){
                SOUND_global_fx_manager_play_tag(.Player_Parry)
                CONST_bullet_stats[b.type].bullet_parry(b,s)
                b.kill_next_frame = true
            }
        }

        if stats.circle_dmg_collision { collision = circles_collide(s_cir, b_cir) }
        else {
            collision = SHIP_body_collides_circle(s, b_cir)
        }

        if collision {
            GAME_kill_bullet(i, blist)
            return true, CONST_bullet_stats[b.type].bullet_dmg, b
        }
        else { i += 1 }
    }
    return false, 0, nil
}

SHIP_body_collides_circle :: proc(s: ^Ship, c: Circle) -> bool {
    rect := SHIP_create_rect(s)
    collision := circle_collides_rect(c, rect)

    return collision
}

SHIP_create_rect :: proc(s: ^Ship) -> Rect {
    stats := &CONST_ship_stats[s.stat_type];
    size := stats.collision_radius * 2 * stats.sprite_scale;
    base_rect := Rect{s.position.x - size/2, s.position.y - size/2, size, size};

    tail_rect := to_rl_rect(ANIMATION_manager_get_dest_frame(&s.tail_anim_manager, base_rect));
    fin_rect  := to_rl_rect(ANIMATION_manager_get_dest_frame(&s.fin_anim_manager, base_rect));
    body_rect := to_rl_rect(ANIMATION_manager_get_dest_frame(&s.body_anim_manager, base_rect));

    scale := stats.sprite_scale;

    rects := [3]^rl.Rectangle{&tail_rect, &fin_rect, &body_rect}
    for r in rects {
        center := FVector{r.x + r.width / 2.0, r.y + r.height / 2.0}
        r.width *= stats.sprite_scale
        r.height *= stats.sprite_scale
        r.x = center.x - r.width / 2.0
        r.y = center.y - r.height / 2.0
    }

    tail_rect_rotated := UTIL_rotate_rectangle(tail_rect, s.position, s.rotation);
    fin_rect_rotated  := UTIL_rotate_rectangle(fin_rect,  s.position, s.rotation);
    body_rect_rotated := UTIL_rotate_rectangle(body_rect, s.position, s.rotation);

    min_x := math.min(tail_rect_rotated.x, math.min(fin_rect_rotated.x, body_rect_rotated.x));
    min_y := math.min(tail_rect_rotated.y, math.min(fin_rect_rotated.y, body_rect_rotated.y));
    max_x := math.max(tail_rect_rotated.x + tail_rect_rotated.width, math.max(fin_rect_rotated.x + fin_rect_rotated.width, body_rect_rotated.x + body_rect_rotated.width));
    max_y := math.max(tail_rect_rotated.y + tail_rect_rotated.height, math.max(fin_rect_rotated.y + fin_rect_rotated.height, body_rect_rotated.y + body_rect_rotated.height));

    width  := max_x - min_x;
    height := max_y - min_y;

    centered_x := s.position.x - width / 2.0;
    centered_y := s.position.y - height / 2.0;


    
    return Rect{centered_x, centered_y, width, height};
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

SHIP_try_parry :: proc(s: ^Ship) -> bool {
    if total_t - s.last_parry_attempt >= PARRY_COOLDOWN_TIME {
        s.last_parry_attempt = total_t
        return true
    }
    return false
}