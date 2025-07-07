package src

import rl "vendor:raylib"
import math "core:math"

// should be a global list of bullets that have radius, damage, and time
// meaning that each bullet on stores what it needs, i.e. pos, vel, elapsed
Bullet :: struct {
    position, velocity: FVector,
    radius: f32,
    time, elapsed: f32,
    damage: f32,
    kill_next_frame: bool,
}

BULLET_create_bullet :: proc(pos: FVector, rot, sp, rad, tm, dmg: f32) -> Bullet {
    return {
        position = pos,
        velocity = FVector{math.cos(rot), -math.sin(rot)} * sp,
        radius = rad,
        time = tm,
        elapsed = 0,
        damage = dmg
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
            sp = CONST_bullet_stats[g.bullet].bullet_speed,
            rad = CONST_bullet_stats[g.bullet].bullet_radius,
            tm = CONST_bullet_stats[g.bullet].bullet_time,
            dmg = CONST_bullet_stats[g.bullet].bullet_dmg,
        )
    )
}

BULLET_update_bullet :: proc(b: ^Bullet, level: ^Level) -> (kill: bool) {
    if b.kill_next_frame { return true }
    new_pos := b.position + b.velocity * dt

    cx, cy := LEVEL_move_with_collision(&b.position, new_pos, b.radius, level)

    if cx || cy { b.kill_next_frame = true }
    
    if b.elapsed >= b.time { return true }
    b.elapsed += dt
    return false
}

BULLET_draw_bullet :: proc(b: ^Bullet, ally: bool = false) {
    col := DMG_COLOR
    if ally { col = ALLY_BULLET_COLOR }
    rl.DrawCircleV(b.position, b.radius, col)
}