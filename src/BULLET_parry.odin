package src

import rl "vendor:raylib"
import math "core:math"
import fmt "core:fmt"

BULLET_parry_success :: proc(s: ^Ship) -> bool{ 
    elapsed := total_t - s.last_parry_attempt
    fmt.printf("%f\n", elapsed)
    if elapsed <= PARRY_WINDOW_TIME {
        return true 
    }
    return false
}

BULLET_parry_signature :: proc(b: ^Bullet)

BULLET_parry_none :: proc(b: ^Bullet){

}

BULLET_parry_default :: proc(b: ^Bullet){
    
}

