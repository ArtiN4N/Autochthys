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
    
    enemy_bullets: [dynamic]Bullet,
    history: [dynamic]MINIBOSS_Eel_History_Point,
    history_size: int,

    head_anim_man: ANIMATION_Manager,
    tail_anim_man: ANIMATION_Manager,
    body_anim_man: ANIMATION_Manager,
    joint_anim_man: ANIMATION_Manager,

    shot_cooldown: f32,
    shot_elapsed: f32,
    shot_dmg: f32,

    shoot_pattern: GUN_shoot_signature,
}

MINIBOSS_Add_Eel_A :: proc(m: ^MINIBOSS_Manager, segments: int) {
    fmt.printfln("making eel entity pointers")

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

    eel.shoot_pattern = GUN_shoot_default

    eel.shot_cooldown = 0.2
    eel.shot_dmg = 10

    eel.body_segments = make([dynamic]MINIBOSS_Eel_Segment, eel.segments, eel.segments)

    eel.head_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Head])
    eel.tail_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Tail])
    eel.body_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Body])
    eel.joint_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Joint])

    eel.head = {
        LEVEL_convert_fcoords_to_real_position({17, 7.5}), 0,
        240
    }
    for i in 0..<eel.segments {
        eel.body_segments[i] = eel.head
    }

    history_max := 256//int(512.0 * (f32(eel.bodies) / 28.0))
    eel.history = make([dynamic]MINIBOSS_Eel_History_Point, history_max, history_max)

    eel.enemy_bullets = make([dynamic]Bullet)

    MINIBOSS_eel_init_ai(eel, &eel.ai)
}

MINIBOSS_destroy_eel_D :: proc(eel: ^MINIBOSS_Eel) {
    fmt.printfln("freeing eel entity pointers")
    delete(eel.history)
    delete(eel.enemy_bullets)
    delete(eel.body_segments)
}

MINIBOSS_eel_fight_update :: proc(game: ^Game, eel: ^MINIBOSS_Eel) {
    // check player take damage with projectiles
    MINIBOSS_eel_handle_player_damage(eel, &game.player)

    MINIBOSS_eel_ai_proc(eel, &eel.ai)

    MINIBOSS_move_eel(eel)


    // move/kill projectiles
    // spawn projectiles
    MINIBOSS_eel_update_projectiles(game, eel)
    MINIBOSS_eel_spawn_projectiles(game, eel)
    
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

MINIBOSS_eel_update_projectiles :: proc(game: ^Game, eel: ^MINIBOSS_Eel) {
    GAME_update_bullets(&eel.enemy_bullets)

    player_hit, player_dmg, bullet := SHIP_check_bullets_collision(&game.player, &eel.enemy_bullets)
    if player_hit { CONST_bullet_stats[bullet.type].bullet_on_hit(bullet, &game.player, player_dmg, &game.level_manager.hit_markers, true)}
}

MINIBOSS_eel_spawn_bullet :: proc(fire_position: FVector, blist: ^[dynamic]Bullet, dmg: f32) {

    target := FVector{ 768 / 2, 768 / 2 }
    face_dir := target - fire_position
    target_rot := math.atan2(face_dir.x, -face_dir.y)

    append(
        blist,
        BULLET_create_bullet(
            pos = fire_position,
            rot = target_rot,
            func = BULLET_function_update_straight,
            t = .Eel,
            dmg = dmg,
        )
    )
}

MINIBOSS_eel_spawn_projectiles :: proc(game: ^Game, eel: ^MINIBOSS_Eel) {
    cons: ^MINIBOSS_Eel_Constrict
    ok: bool
    if cons, ok = &eel.ai.state.(MINIBOSS_Eel_Constrict); !ok do return

    if !cons.reached_start do return 

    if eel.shot_elapsed >= eel.shot_cooldown {
        eel.shot_elapsed = 0

        for s in 0..<eel.segments {
            spawn_position := eel.body_segments[s].position

            MINIBOSS_eel_spawn_bullet(spawn_position, &eel.enemy_bullets, eel.shot_dmg)            
        }
        SOUND_global_fx_manager_play_tag(.Ship_Shoot)
    }

    eel.shot_elapsed += dt
}

MINIBOSS_eel_fight_draw :: proc(game: ^Game, eel: ^MINIBOSS_Eel) {
    // draw projectiles
    for &b in &eel.enemy_bullets {
        BULLET_draw_bullet(&b)
    }

    // draw eel
    MINIBOSS_eel_draw_segment(eel, &eel.tail_anim_man, eel.body_segments[eel.segments - 1].position, eel.body_segments[eel.segments - 1].rotation)

    i := eel.segments - 2
    for i >= 0 {
        if i > 0 {
            // joint
            joint_pos := (eel.body_segments[i - 1].position + eel.body_segments[i].position) / 2
            if vector_dist(eel.body_segments[i - 1].position, eel.body_segments[i].position) <= eel.spacing * 2 {
                MINIBOSS_eel_draw_segment(eel, &eel.joint_anim_man, joint_pos, eel.body_segments[i].rotation)
            }
            
        }

        if i == 0 {
            joint_pos := (eel.head.position + eel.body_segments[i].position) / 2
            if vector_dist(eel.head.position, eel.body_segments[i].position) <= eel.spacing * 2 {
                MINIBOSS_eel_draw_segment(eel, &eel.joint_anim_man, joint_pos, eel.body_segments[i].rotation)
            }
        }
        

        MINIBOSS_eel_draw_segment(eel, &eel.body_anim_man, eel.body_segments[i].position, eel.body_segments[i].rotation)
       

        i -= 1
    }

    temp_head_rotation := eel.head.rotation + eel.rotation_modulation
    if _, ok := eel.ai.state.(MINIBOSS_Eel_Constrict); ok {
        temp_head_rotation = eel.head.rotation
    }
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
