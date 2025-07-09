package src

import rl "vendor:raylib"
import math "core:math"

BULLET_on_hit :: proc(b: ^Bullet, s: ^Ship, dmg: f32, hit_markers: ^[dynamic]STATS_Hitmarker)

BULLET_on_hit_default :: proc(b: ^Bullet, s: ^Ship, dmg: f32, hit_markers: ^[dynamic]STATS_Hitmarker){
    b.kill_next_frame = true
    if !b.parry || !BULLET_parry_success(s) {
        SHIP_try_take_damage(s, dmg, hit_markers) //Try to parry. if not, deal damage
        return
    }
    SOUND_global_fx_manager_play_tag(.Player_Xp_Pickup)
    CONST_bullet_stats[b.type].bullet_parry(b) 
}

BULLET_on_hit_blue ::  proc(b: ^Bullet, s: ^Ship, dmg: f32, hit_markers: ^[dynamic]STATS_Hitmarker){
    b.kill_next_frame = true
    
}

