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

STATS_update_exp :: proc(e: ^STATS_Experience, player_pos: FVector/*, level: LEVEL_Data*/) {
    if e.velocity.x == 0 && e.velocity.y == 0 {
        dist := player_pos - e.position
        dir := vector_normalize(dist)

        // speed should get faster the closer they are to player
        dist_factor := min(STATS_EXP_MAX_SPEED_FACTOR, (100 / vector_magnitude(dist)))
        speed: f32 = STATS_EXP_MAGNET_SPEED * dist_factor
        e.position += dir * speed * dt

        return
    }

    e.position += e.velocity * dt
    new_vel := e.velocity * math.pow(STATS_EXP_DAMPER, dt)

    if e.velocity.x < 0 && new_vel.x > -STATS_EXP_MIN_VELOCITY { new_vel.x = 0 }
    if e.velocity.x > 0 && new_vel.x < STATS_EXP_MIN_VELOCITY { new_vel.x = 0 }

    if e.velocity.y < 0 && new_vel.y > -STATS_EXP_MIN_VELOCITY { new_vel.y = 0 }
    if e.velocity.y > 0 && new_vel.y < STATS_EXP_MIN_VELOCITY { new_vel.y = 0 }

    e.velocity = new_vel

    total_speed := vector_magnitude(e.velocity)
    rotate_speed := 360 * total_speed / 300

    rotate_factor: f32 = 1
    if e.clockwise { rotate_factor = -1 }
    e.angle += dt * rotate_speed * rotate_factor
    if e.angle > 360 { e.angle = 0 }
    if e.angle < 0 { e.angle = 360}

    //test_size := FVector{STATS_EXP_PICKUP_SIZE * 2, STATS_EXP_PICKUP_SIZE * 2}
    //test_pos := e.position - test_size / 2
    //test_rect := rect_from_vecs(test_pos, test_size)
    //test_rect.y += 1
    //e.grounded = LEVEL_check_rect_collides(test_rect, level)

    //if e.grounded {
        //if e.velocity.y > 0 && e.velocity.y < 20 { e.velocity.y = 0 }
        //if e.velocity.y < 0 && e.velocity.y > -20 { e.velocity.y = 0 }
    //}

    //if !e.grounded || e.velocity.y != 0 {
        //e.velocity.y += STATS_EXP_GRAV_ACCEL * dt
    //}

    //update_position := e.position + e.velocity * dt
    //STATS_decay_exp_vel(e)

    //collider := rect_from_vecs(e.position, e.size)
    //corrected_pos, collided_x, collided_y, should_ground := LEVEL_correct_rect_collision(collider, update_position, level)

    //if should_ground && e.velocity.y > 0 && e.velocity.y < 25 {
        //e.grounded = true
        //e.velocity.y = 0
    //}

    //e.position = corrected_pos
    // bouncing like this should be abstracted to a collision correction function
    //if collided_x { e.velocity.x *= -STATS_EXP_BOUNCE_DAMPER }
    //if collided_y {
        //e.velocity.y *= -STATS_EXP_BOUNCE_DAMPER
    //}
}

STATS_EXP_PICKUP_RANGE :: 10
STATS_check_exp_pickup :: proc(e: ^STATS_Experience, pickup_collider: Rect) -> bool {
    pickup_cir := Circle{e.position.x, e.position.y, STATS_EXP_PICKUP_RANGE}
    
    return circle_collides_rect(pickup_cir, pickup_collider)
}