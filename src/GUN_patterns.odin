package src

import math "core:math"

GUN_shoot_signature :: proc(g: ^Gun, pos: FVector, rot: f32, blist: ^[dynamic]Bullet)

GUN_shoot_none :: proc(g: ^Gun, pos: FVector, rot: f32, blist: ^[dynamic]Bullet){
    return
}

GUN_shoot_default :: proc(g: ^Gun, pos: FVector, rot: f32, blist: ^[dynamic]Bullet){
    BULLET_spawn_bullet(g, pos, rot, blist)
}

GUN_shoot_eight :: proc(g: ^Gun, pos: FVector, rot: f32, blist: ^[dynamic]Bullet){
    for i := 0; i < 8; i += 1 {
        BULLET_spawn_bullet(g, pos, rot + math.PI / 4.0 * f32(i), blist)
    }

}