package src

import rl "vendor:raylib"
import math "core:math"
import rand "core:math/rand"

// should be a global list of bullets that have radius, damage, and time
// meaning that each bullet on stores what it needs, i.e. pos, vel, elapsed
Bullet :: struct {
    type: CONST_Bullet_Type,
    position, velocity: FVector,
    init_position: FVector,
    elapsed: f32,
    kill_next_frame: bool,
    parry: bool,
    function: BULLET_function_update_signature,
}

BULLET_create_bullet :: proc(pos: FVector, rot: f32, func: BULLET_function_update_signature, t: CONST_Bullet_Type) -> Bullet {
    return {
        type = t,
        position = pos,
        init_position = pos,
        velocity = FVector{math.cos(rot), -math.sin(rot)} * CONST_bullet_stats[t].bullet_speed,
        elapsed = 0,
        function = func,
        parry = rand.int31_max(2, rng) == 1 //probably bad optimization but just temporary i guess
    }
}

BULLET_spawn_bullet :: proc(g: ^Gun, ship_pos: FVector, gun_rot: f32, blist: ^[dynamic]Bullet) {
    if g.bullet == CONST_Bullet_Type.None { return }

    dir := FVector{ math.cos(gun_rot), -math.sin(gun_rot) }
    spawn_pos := g.dist_from_ship * dir + ship_pos
    append(
        blist,
        BULLET_create_bullet(
            pos = spawn_pos,
            rot = gun_rot,
            func = g.bullet_function,
            t = g.bullet,
        )
    )
}

BULLET_update_bullet :: proc(b: ^Bullet) -> (kill: bool) {
    if b.kill_next_frame { return true }

    new_pos := b.function(b)

    cx, cy := LEVEL_global_move_with_collision(&b.position, new_pos, CONST_bullet_stats[b.type].bullet_radius)

    if cx || cy { b.kill_next_frame = true } //Call onhit function
    
    if b.elapsed >= CONST_bullet_stats[b.type].bullet_time { return true }
    b.elapsed += dt
    return false
}

BULLET_draw_bullet :: proc(b: ^Bullet, ally: bool = false) {
    col := DMG_COLOR
    if b.parry { col = PARRY_BULLET_COLOR}
    if ally { col = ALLY_BULLET_COLOR }
    rl.DrawCircleV(b.position, CONST_bullet_stats[b.type].bullet_radius, col)
}