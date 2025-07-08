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