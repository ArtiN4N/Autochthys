package src

import rl "vendor:raylib"
import math "core:math"
import "core:fmt"

BULLET_function_update :: proc(b: ^Bullet) -> (newpos: rl.Vector2){
    switch b.function{
        case .Straight:
            return BULLET_function_update_straight(b)
        case .Sine:
            return BULLET_function_update_sine(b)
    }
    return b.position
}

BULLET_function_update_straight :: proc(b: ^Bullet) -> (newpos: rl.Vector2){
    return b.init_position + b.elapsed * b.velocity
}

BULLET_function_update_sine :: proc(b: ^Bullet) -> (newpos: rl.Vector2){
    new := b.init_position + b.elapsed * b.velocity
    new.y += math.sin(b.elapsed * 30) * 5
    return new
}