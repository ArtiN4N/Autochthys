package src

import rl "vendor:raylib"
import math "core:math"
import "core:fmt"

BULLET_function_update_signature :: proc(b: ^Bullet) -> (newpos: FVector)

BULLET_function_update_none :: proc(b: ^Bullet) -> (newpos: FVector){
    return b.position
}

BULLET_function_update_straight :: proc(b: ^Bullet) -> (newpos: FVector){
    return b.init_position + b.elapsed * b.velocity
}

BULLET_function_update_sine :: proc(b: ^Bullet) -> (newpos: FVector){
    new := b.init_position + b.elapsed * b.velocity
    new.y += math.sin(b.elapsed * 30) * 5
    return new
}

BULLET_function_update_curve_right :: proc(b: ^Bullet) -> (newpos: FVector) {
    new := b.init_position + b.elapsed * b.velocity

    curve_strength: f32 = 1.5 
    angle := b.elapsed * curve_strength

    cos_theta := math.cos(angle)
    sin_theta := math.sin(angle)

    v := b.velocity
    rotated_velocity := FVector{v.x * cos_theta + v.y * sin_theta, v.y * cos_theta - v.x * sin_theta}

    curved_pos := b.init_position + b.elapsed * rotated_velocity
    return curved_pos
}