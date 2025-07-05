package src

import rl "vendor:raylib"
import math "core:math"

// should be a global list of bullets that have radius, damage, and time
// meaning that each bullet on stores what it needs, i.e. pos, vel, elapsed
SHIP_Bullet :: struct {
    position, velocity: FVector,
    radius: f32,
    time, elapsed: f32,
    damage: f32,
}

SHIP_create_bullet :: proc(pos: FVector, rot, sp, rad, tm, dmg: f32) -> SHIP_Bullet {
    return {
        position = pos,
        velocity = FVector{math.cos(rot), -math.sin(rot)} * sp,
        radius = rad,
        time = tm,
        elapsed = 0,
        damage = dmg
    }
}

SHIP_spawn_bullet :: proc(g: ^SHIP_Gun, ship_pos: FVector, gun_rot: f32, blist: ^[dynamic]SHIP_Bullet) {
    dir := FVector{ math.cos(gun_rot), -math.sin(gun_rot) }
    spawn_pos := g.dist_from_ship * dir + ship_pos
    append(
        blist,
        SHIP_create_bullet(
            pos = spawn_pos,
            rot = gun_rot,
            sp = g.bullet_speed,
            rad = g.bullet_radius,
            tm = g.bullet_time,
            dmg = g.bullet_damage
        )
    )
}

SHIP_update_bullet :: proc(b: ^SHIP_Bullet) -> (kill: bool) {
    b.position += b.velocity * dt

    rw, rh := APP_get_global_render_size()
    if b.position.x < -b.radius { return true }
    if b.position.x > f32(rw) + b.radius { return true }
    if b.position.y < -b.radius { return true }
    if b.position.y > f32(rh) + b.radius { return true }
    
    if b.elapsed >= b.time { return true }
    b.elapsed += dt
    return false
}

SHIP_draw_bullet :: proc(b: ^SHIP_Bullet, ally: bool = false) {
    col := DMG_COLOR
    if ally { col = ALLY_BULLET_COLOR }
    rl.DrawCircleV(b.position, b.radius, col)
}