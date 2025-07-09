package src

import rl "vendor:raylib"
import math "core:math"

BULLET_on_hit :: proc(b: ^Bullet, s: ^Ship, dmg: f32, hit_markers: ^[dynamic]STATS_Hitmarker)

BULLET_on_hit_default :: proc(b: ^Bullet, s: ^Ship, dmg: f32, hit_markers: ^[dynamic]STATS_Hitmarker){
    SHIP_try_take_damage(s, dmg, hit_markers) 
}

BULLET_on_hit_blue ::  proc(b: ^Bullet, s: ^Ship, dmg: f32, hit_markers: ^[dynamic]STATS_Hitmarker){
    
}

