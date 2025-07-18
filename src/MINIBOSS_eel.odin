package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"

MINIBOSS_Eel_History_Point :: struct {
    position: FVector,
    dist: f32,
}

lin_interp :: proc(a, b: FVector, t: f32) -> FVector {
    return a + t * (b - a)
}

MINIBOSS_Eel_Segment :: struct {
    position: FVector,
    rotation: f32,
    hp: f32,
}

// The eel is an enemy with multiple segments
MINIBOSS_Eel :: struct {
    eel_idx: int,
    ai: MINIBOSS_Eel_AI,

    move_dir: FVector,

    bodies: int,
    segments: int,
    lower_bodies: int,

    segment_damage: f32,

    spacing: f32,
    segment_damage_radius: f32,

    body_segments: [dynamic]MINIBOSS_Eel_Segment,
    head: MINIBOSS_Eel_Segment,

    rotation_modulation: f32,
    rotation_modulation_dir: f32,
    

    history: [dynamic]MINIBOSS_Eel_History_Point,
    history_size: int,

    head_anim_man: ANIMATION_Manager,
    tail_anim_man: ANIMATION_Manager,
    lower_body_anim_man: ANIMATION_Manager,
    upper_body_anim_man: ANIMATION_Manager,
}

MINIBOSS_Add_Eel_A :: proc(m: ^MINIBOSS_Manager, segments: int) {
    append(&m.eel, MINIBOSS_Eel{})
    eel := &m.eel[len(m.eel) - 1]

    eel.eel_idx = len(m.eel) - 1

    anim_collections := &APP_global_app.game.animation_collections

    eel.bodies = segments - 1
    eel.segments = segments
    eel.lower_bodies = segments - 2

    eel.spacing = 60
    eel.segment_damage_radius = 40
    eel.segment_damage = 40

    eel.rotation_modulation = 0
    eel.rotation_modulation_dir = 1

    eel.body_segments = make([dynamic]MINIBOSS_Eel_Segment, eel.segments, eel.segments)

    eel.head_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Head])
    eel.tail_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Tail])
    eel.upper_body_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Upper])
    eel.lower_body_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Lower])

    eel.head = {
        LEVEL_convert_fcoords_to_real_position({4.5, 7.5}), 0,
        1200
    }
    for i in 0..<eel.segments {
        eel.body_segments[i] = eel.head
    }

    history_max := int(512.0 * (f32(eel.bodies) / 28.0))
    eel.history = make([dynamic]MINIBOSS_Eel_History_Point, history_max, history_max)

    MINIBOSS_eel_init_ai(eel, &eel.ai)
}

MINIBOSS_destroy_eel_D :: proc(eel: ^MINIBOSS_Eel) {
    delete(eel.history)
    delete(eel.body_segments)
}

MINIBOSS_eel_fight_update :: proc(game: ^Game, eel: ^MINIBOSS_Eel) {
    // check player take damage with projectiles
    MINIBOSS_eel_handle_player_damage(eel, &game.player)

    MINIBOSS_eel_ai_proc(eel, &eel.ai)

    MINIBOSS_move_eel(eel)


    // move/kill projectiles
    // spawn projectiles
    
    MINIBOSS_eel_handle_damage_from_player(game, eel)

    if MINIBOSS_eel_handle_death_split(game, eel) {
        rm_idx := eel.eel_idx
        MINIBOSS_destroy_eel_D(eel)
        unordered_remove(&game.miniboss_manager.eel, rm_idx)

        i := 0
        for &e in &game.miniboss_manager.eel {
            e.eel_idx = i
            i += 1
        }
        return
    }
}

MINIBOSS_eel_fight_draw :: proc(game: ^Game, eel: ^MINIBOSS_Eel) {
    // draw projectiles
    // draw eel
    MINIBOSS_eel_draw_segment(eel, &eel.tail_anim_man, eel.body_segments[eel.segments - 1].position, eel.body_segments[eel.segments - 1].rotation)

    //s := 0
    for i in 0..<eel.lower_bodies {
        j := eel.segments - 2 - i
        MINIBOSS_eel_draw_segment(eel, &eel.lower_body_anim_man, eel.body_segments[j].position, eel.body_segments[j].rotation)
        //s += 1
    }

    MINIBOSS_eel_draw_segment(eel, &eel.upper_body_anim_man, eel.body_segments[0].position, eel.body_segments[0].rotation)

    temp_head_rotation := eel.head.rotation + eel.rotation_modulation 
    MINIBOSS_eel_draw_segment(eel, &eel.head_anim_man, eel.head.position, temp_head_rotation)
}

MINIBOSS_eel_draw_segment :: proc(eel: ^MINIBOSS_Eel, anim_man: ^ANIMATION_Manager, position: FVector, rotation: f32) {
    size := anim_man.collection.animations[.ANIMATION_IDLE_TAG].sheet_size
    draw_rect := Rect{position.x - f32(size.x) / 2, position.y - f32(size.y) / 2, f32(size.x), f32(size.y)}

    src_frame := to_rl_rect(ANIMATION_manager_get_src_frame(anim_man))

    dest_frame := to_rl_rect(ANIMATION_manager_get_dest_frame(anim_man, draw_rect))
    dest_origin := ANIMATION_manager_get_dest_origin(anim_man, dest_frame)

    tex_sheet := anim_man.collection.entity_type
    rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, rotation * rl.RAD2DEG, rl.WHITE)

    //rl.DrawCircleV(position, eel.segment_damage_radius, {255, 0, 255, 100})
}
