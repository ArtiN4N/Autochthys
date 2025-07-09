package src

import rl "vendor:raylib"
import math "core:math"
import fmt "core:fmt"

BULLET_parry_success :: proc(b: ^Bullet, s: ^Ship) -> bool{ 
    if(CONST_bullet_stats[b.type].bullet_parry == BULLET_parry_none) { return false}
    if !b.parry { return false }
    
    elapsed := total_t - s.last_parry_attempt
    fmt.printf("%f\n", elapsed)
    if elapsed <= PARRY_WINDOW_TIME {
        return true 
    }
    return false
}

BULLET_parry_signature :: proc(b: ^Bullet, s: ^Ship)

BULLET_parry_none :: proc(b: ^Bullet, s: ^Ship){

}

BULLET_parry_default :: proc(b: ^Bullet, s: ^Ship){
    s.gun.ammo = s.gun.max_ammo
}

