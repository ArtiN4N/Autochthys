package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"
import rand "core:math/rand"

SHIP_draw :: proc(s: ^Ship, ally: bool = false) {
    stats := &CONST_ship_stats[s.stat_type]

    size := stats.collision_radius * 2
    draw_collision_rect := Rect{ s.position.x - size / 2, s.position.y - size / 2, size, size}

    col := rl.WHITE
    //if ally { col = ALLY_SHIP_COLOR }
    //if stats.lethal_body { col = DMG_COLOR }

    draw_position := s.position
    
    if s.invincibility_active {
        col.a = SHIP_get_invincibility_draw_opacity(s.invincibility_elapsed)
    }

    if s.damaged_active {
        draw_position += SHIP_get_damaged_draw_offset(s.damaged_elapsed)
    }

    if s.gun.cooldown_active {
        draw_position += SHIP_get_recoil_draw_offset(s.rotation, s.gun.elapsed, s.gun.cooldown)
    }

    //verts := SHIP_get_draw_verts(s, draw_position)
    //rl.DrawTriangleFan(raw_data(&verts), 4, col)

    texture_rot := -rl.RAD2DEG * (s.rotation - math.PI / 2)
    parts_texture_rot := -rl.RAD2DEG * (s.parts_rotation - math.PI / 2)

    //body
    dest_frame := to_rl_rect(ANIMATION_manager_get_dest_frame(&s.body_anim_manager, draw_collision_rect))
    src_frame := to_rl_rect(ANIMATION_manager_get_src_frame(&s.body_anim_manager))
    dest_origin := ANIMATION_manager_get_dest_origin(&s.body_anim_manager, dest_frame)
    tex_sheet := s.body_anim_manager.collection.entity_type
    rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, texture_rot, col)

    //tail
    dest_frame = to_rl_rect(ANIMATION_manager_get_dest_frame(&s.tail_anim_manager, draw_collision_rect))
    src_frame = to_rl_rect(ANIMATION_manager_get_src_frame(&s.tail_anim_manager))
    dest_origin = ANIMATION_manager_get_dest_origin(&s.tail_anim_manager, dest_frame)
    tex_sheet = s.tail_anim_manager.collection.entity_type
    rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, parts_texture_rot, col)

    //fin
    dest_frame = to_rl_rect(ANIMATION_manager_get_dest_frame(&s.fin_anim_manager, draw_collision_rect))
    src_frame = to_rl_rect(ANIMATION_manager_get_src_frame(&s.fin_anim_manager))
    dest_origin = ANIMATION_manager_get_dest_origin(&s.fin_anim_manager, dest_frame)
    tex_sheet = s.fin_anim_manager.collection.entity_type
    rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, parts_texture_rot, col)

    rl.DrawRectangleRec(to_rl_rect(draw_collision_rect), rl.Color{230, 90, 150, 100})
    
    //rl.DrawCircleV(s.position, stats.collision_radius, rl.Color{255, 0, 0, 100})
    //rl.DrawCircleV(s.position, PARRY_RADIUS, rl.Color{230, 90, 150, 100})
}

SHIP_get_invincibility_draw_opacity :: proc(elapsed: f32) -> u8 {
    invincibility_max_opacity := 255
    invincibility_min_opacity := 100
    invincibility_seconds_p_flash: f32 = 0.3

    quotient := int( (elapsed * 10) / (invincibility_seconds_p_flash * 10) )
    remainder := (elapsed * 10) / (invincibility_seconds_p_flash * 10) - f32(quotient)
    opacity_range := invincibility_max_opacity - invincibility_min_opacity
    current_opacity := invincibility_min_opacity + int( remainder * f32(opacity_range) )

    return u8(current_opacity)
}

SHIP_get_damaged_draw_offset :: proc(elapsed: f32) -> FVector {
    rx := rand.float32()
    ry := rand.float32()
    rd := rand.float32() * SHIP_DAMAGE_SHAKE_MAX_DIST

    dir := vector_normalize({rx, ry})

    return dir * rd
}

SHIP_get_recoil_draw_offset :: proc(theta, elapsed, cooldown: f32) -> FVector {
    theta := theta + math.PI
    dir := FVector{ math.cos(theta), -math.sin(theta) }

    cooldown := min(cooldown / 2, 1)

    ratio := min(1, elapsed / cooldown)
    max_dist: f32 = 3

    return dir * max_dist * (1 - ratio)
}


SHIP_get_draw_verts :: proc(s: Ship, pos: FVector) -> [4]FVector {
    stats := &CONST_ship_stats[s.stat_type]

    vert_dist := stats.tip_radius
    tail_dist := stats.tip_radius / SHIP_TAIL_RADIUS_DIV

    // ship rotations are in rad
    rot_rad := s.rotation// * math.RAD_PER_DEG

    theta1: f32 = SHIP_TIP_THETA + rot_rad
    theta2: f32 = SHIP_LEFT_TAIL_THETA + rot_rad
    theta3: f32 = SHIP_MID_TAIL_THETA + rot_rad
    theta4: f32 = SHIP_RIGHT_TAIL_THETA + rot_rad

    verts: [4]FVector = {
        FVector{math.cos(theta1), -math.sin(theta1)} * vert_dist + pos,
        FVector{math.cos(theta2), -math.sin(theta2)} * vert_dist + pos,
        FVector{math.cos(theta3), -math.sin(theta3)} * tail_dist + pos,
        FVector{math.cos(theta4), -math.sin(theta4)} * vert_dist + pos
    }

    return verts
}
