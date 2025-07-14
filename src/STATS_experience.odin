package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"
import rand "core:math/rand"

STATS_Experience :: struct {
    position: FVector,
    size: FVector,
    velocity: FVector,

    exp: f32,

    angle: f32,
    clockwise: bool,
}

STATS_global_create_exp :: proc(pos: FVector, exp: f32) {
    e: STATS_Experience

    e.position = pos
    e.size = {STATS_EXP_PICKUP_SIZE, STATS_EXP_PICKUP_SIZE}
    e.velocity = vector_normalize({rand.float32() * 2 - 1, rand.float32() * 2 - 1}) * STATS_EXP_START_SPEED * rand.float32() * 2 + 0.5

    e.exp = exp
    e.angle = 0
    e.clockwise = false
    if rand.float32() > 0.5 {e.clockwise = true }
    
    level_man := &APP_global_app.game.level_manager

    append(&level_man.exp_points, e)
}

STATS_draw_exp :: proc(e: STATS_Experience) {
    rl.DrawPoly(e.position, 5, STATS_EXP_PICKUP_SIZE, e.angle, EXP_COLOR)
}

STATS_update_exp :: proc(e: ^STATS_Experience, player_pos: FVector) {
    if vector_magnitude(e.velocity) < STATS_EXP_MIN_SPEED {
        dist := player_pos - e.position
        dir := vector_normalize(dist)

        // speed should get faster the closer they are to player
        dist_factor := min(STATS_EXP_MAX_SPEED_FACTOR, (100 / vector_magnitude(dist)))
        speed: f32 = STATS_EXP_MAGNET_SPEED * dist_factor
        e.position += dir * speed * dt

        return
    }
    
    new_pos := e.position + e.velocity * dt
    cx, cy := LEVEL_global_move_with_collision(&e.position, new_pos, STATS_EXP_PICKUP_SIZE)
    new_vel := e.velocity * math.pow(STATS_EXP_DAMPER, dt)
    if cx { new_vel.x *= -1 } 
    if cy { new_vel.y *= -1 }
    e.velocity = new_vel

    total_speed := vector_magnitude(e.velocity)
    rotate_speed := 360 * total_speed / 300

    rotate_factor: f32 = 1
    if e.clockwise { rotate_factor = -1 }
    e.angle += dt * rotate_speed * rotate_factor
    if e.angle > 360 { e.angle = 0 }
    if e.angle < 0 { e.angle = 360}
}

STATS_check_exp_pickup :: proc(e: ^STATS_Experience, pickup_collider: Rect) -> bool {
    pickup_cir := Circle{e.position.x, e.position.y, STATS_EXP_PICKUP_RANGE}
    
    return circle_collides_rect(pickup_cir, pickup_collider)
}

STATS_scale_exp_by_world_scale :: proc(exp: f32, world_scale: int) -> f32 {
    ret: f32
    switch world_scale {
    case 1:
        ret = exp
    case 2:
        ret = exp * 10
    case:
        fallthrough
    case 3:
        ret = exp * 50
    }
    return ret
}

STATS_global_spawn_exp_proc :: proc(enemy_max_hp: f32, position: FVector) {
    man := &APP_global_app.game.stats_manager

    total_exp := int(STATS_scale_exp_by_world_scale(enemy_max_hp, man.world_scale) * man.boon_enemy_exp_scale)

    #reverse for denom in STATS_EXP_DENOMS {
        spawn := 0
        for denom <= total_exp {
            spawn += 1
            total_exp -= denom
        }
        for i in 0..<spawn {
            STATS_global_create_exp(position, f32(denom))
        }
    }

    if total_exp <= 0 do return
    STATS_global_create_exp(position, f32(total_exp))
}

STATS_global_player_collect_exp :: proc(exp: f32) {
    man := &APP_global_app.game.stats_manager

    man.experience += exp * (rand.float32() * 0.6 + 0.7)

    
    required := STATS_level_up_requirement(man.level)

    if man.experience >= required {
        man.level += 1
        man.points += 1
        man.experience -= required

        SOUND_global_fx_manager_play_tag(.Player_Levelup)
    
    }
}

STATS_level_up_requirement :: proc(l: int) -> f32 {
    if l < 11 do return STATS_level_up_requirements_before_before_11[l]
    else do return STATS_level_up_requirement_after_11(f32(l))
}

@(rodata)
STATS_level_up_requirements_before_before_11 := []f32{
    50,
    110,
    180,
    250,
    350,
    475,
    600,
    800,
    1000,
    1200,
    1400,
}

STATS_level_up_requirement_after_11 :: proc(l: f32) -> f32 {
    return 0.6 * math.pow(l, 3.2)
} 
