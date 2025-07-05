package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"
import rand "core:math/rand"

STATS_Experience :: struct {
    position: FVector,
    size: FVector,
    velocity: FVector,

    angle: f32,
    clockwise: bool,
}

STATS_create_exp :: proc(pos, vel: FVector) -> (e: STATS_Experience) {
    e.position = pos
    e.size = {STATS_EXP_PICKUP_SIZE, STATS_EXP_PICKUP_SIZE}
    e.velocity = vel

    e.angle = 0
    e.clockwise = false
    if rand.float32() > 0.5 {e.clockwise = true }
    return e
}

STATS_draw_exp :: proc(e: STATS_Experience) {
    rl.DrawPoly(e.position, 3, STATS_EXP_PICKUP_SIZE, e.angle, EXP_COLOR)
}

STATS_update_exp :: proc(e: ^STATS_Experience, player_pos: FVector, level: ^Level) {
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
    cx, cy := LEVEL_move_with_collision(&e.position, new_pos, STATS_EXP_PICKUP_SIZE, level)
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

STATS_EXP_PICKUP_RANGE :: 10
STATS_check_exp_pickup :: proc(e: ^STATS_Experience, pickup_collider: Rect) -> bool {
    pickup_cir := Circle{e.position.x, e.position.y, STATS_EXP_PICKUP_RANGE}
    
    return circle_collides_rect(pickup_cir, pickup_collider)
}