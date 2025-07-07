package src

import rl "vendor:raylib"

BULLET_Function_Type :: enum {
    Straight,
}

BULLET_function_update :: proc(b: ^Bullet) -> (newpos: rl.Vector2){
    switch b.function{
        case .Straight:
            return BULLET_function_update_straight(b)
    }
    return b.position
}

BULLET_function_update_straight :: proc(b: ^Bullet) -> (newpos: rl.Vector2){
    return b.init_position + b.elapsed * b.velocity
}