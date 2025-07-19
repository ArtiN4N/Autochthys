package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"

MINIBOSS_eel_check_player_damage :: proc(eel: ^MINIBOSS_Eel, player: ^Ship) -> bool {
    stats := &CONST_ship_stats[player.stat_type]
    p_cir := Circle{ player.position.x, player.position.y, stats.collision_radius}

    head_cir := Circle{eel.head.position.x, eel.head.position.y, eel.segment_damage_radius}

    if circles_collide(p_cir, head_cir) do return true

    for i in 0..<eel.segments {
        seg_cir := Circle{eel.body_segments[i].position.x, eel.body_segments[i].position.y, eel.segment_damage_radius}
        if circles_collide(p_cir, seg_cir) do return true
    }

    return false
}

MINIBOSS_eel_handle_player_damage :: proc(eel: ^MINIBOSS_Eel, player: ^Ship) {
    if ! MINIBOSS_eel_check_player_damage(eel, player) do return

    SHIP_try_take_damage(player, eel.segment_damage, &APP_global_app.game.level_manager.hit_markers, true) 
}

MINIBOSS_eel_handle_damage_from_player :: proc(game: ^Game, eel: ^MINIBOSS_Eel) {
    i := 0
    for &b in &game.level_manager.ally_bullets {
        defer i += 1
        b_cir := Circle{ b.position.x, b.position.y, CONST_bullet_stats[b.type].bullet_radius }

        dmg: f32 = 0
        seg := 0
        head := false

        each_seg: {
            head_cir := Circle{eel.head.position.x, eel.head.position.y, eel.segment_damage_radius}
            if circles_collide(b_cir, head_cir) {
                GAME_kill_bullet(i, &game.level_manager.ally_bullets)
                dmg = STATS_global_player_damage()
                i -= 1
                head = true
                break each_seg
            }

            for s in 0..<eel.segments {
                seg_cir := Circle{eel.body_segments[s].position.x, eel.body_segments[s].position.y, eel.segment_damage_radius}
                if circles_collide(b_cir, seg_cir) {
                    GAME_kill_bullet(i, &game.level_manager.ally_bullets)
                    dmg = STATS_global_player_damage()
                    i -= 1
                    seg = s
                    break each_seg
                }
            }
        }
        

        if dmg == 0 do continue

        MINIBOSS_eel_damage_segment(eel, dmg, seg, head)
    }
}

MINIBOSS_eel_damage_segment :: proc(eel: ^MINIBOSS_Eel, dmg: f32, seg: int, head: bool = false) {
    SOUND_global_fx_choose_enemy_hit_sound()

    if head {
        eel.head.hp -= dmg
        append(&APP_global_app.game.level_manager.hit_markers, STATS_create_hitmarker(eel.head.position, dmg))
        return
    }

    append(&APP_global_app.game.level_manager.hit_markers, STATS_create_hitmarker(eel.body_segments[seg].position, dmg))
    eel.body_segments[seg].hp -= dmg
}

MINIBOSS_eel_handle_death_split :: proc(game: ^Game, eel: ^MINIBOSS_Eel) -> (kill: bool){
    miniboss_man := &game.miniboss_manager

    split_sfx := false
    defer if split_sfx do SOUND_global_fx_choose_eel_split_sound()

    // if head dies, then keep the same eel
    for eel.head.hp <= 0 || eel.body_segments[0].hp <= 0 || eel.body_segments[1].hp <= 0 {
        split_sfx = true
        // head died, so move everything up
        eel.head = eel.body_segments[0]
        i := 0
        for i < eel.segments - 1 {
            defer i += 1
            eel.body_segments[i] = eel.body_segments[i + 1]
        }
        // forget the tail
        unordered_remove(&eel.body_segments, i)

        //update counting
        eel.bodies -= 1
        eel.segments -= 1
        eel.lower_bodies -= 1

        if eel.segments < 2 {
            return true
        }
    }

    i := eel.segments - 1
    end_elim := false
    if i >= 0 do end_elim |= eel.body_segments[i].hp <= 0
    if i - 1 >= 0 do end_elim |= eel.body_segments[i - 1].hp <= 0
    if i - 2 >= 0 do end_elim |= eel.body_segments[i - 2].hp <= 0

    for end_elim {
        split_sfx = true
        unordered_remove(&eel.body_segments, i)
        eel.bodies -= 1
        eel.segments -= 1
        eel.lower_bodies -= 1

        i = eel.segments - 1
        if i < 0 do break

        if eel.segments < 2 {
            return true
        }

        end_elim = false
        if i >= 0 do end_elim |= eel.body_segments[i].hp <= 0
        if i - 1 >= 0 do end_elim |= eel.body_segments[i - 1].hp <= 0
        if i - 2 >= 0 do end_elim |= eel.body_segments[i - 2].hp <= 0
    }

    for seg in 2..<(i - 3) {
        if eel.body_segments[seg].hp > 0 do continue
        split_sfx = true

        old_segments := seg
        new_segments := eel.segments - seg - 1
        //split da eel
        MINIBOSS_Add_Mini_Eel_A(&game.miniboss_manager, eel, seg, new_segments)

        //cap da old eel
        eel.bodies = old_segments - 1
        eel.segments = old_segments
        eel.lower_bodies = old_segments - 2
        for i in 0..<(new_segments+1) {
            unordered_remove(&eel.body_segments, seg)

            //fmt.printfln("old hist:\n\t%v\n\n\n", eel.history)

            new_hist_max := int(512.0 * (f32(eel.bodies) / 28.0))
            full_len := len(eel.history)

            if full_len > new_hist_max {
                offset := full_len - new_hist_max

                for j in 0..<new_hist_max {
                    eel.history[j] = eel.history[j + offset]
                }

                for len(eel.history) > new_hist_max {
                    unordered_remove(&eel.history, new_hist_max)
                }
            }

            eel.history[0].dist = 0
            for i in 1..<len(eel.history) {
                prev := eel.history[i-1].position
                curr := eel.history[i].position

                eel.history[i].dist = eel.history[i-1].dist + vector_magnitude(curr - prev)
            }

            if eel.history_size >= new_hist_max do eel.history_size = new_hist_max - 1
        }

        break
    }

    return false
}

MINIBOSS_Add_Mini_Eel_A :: proc(m: ^MINIBOSS_Manager, old_eel: ^MINIBOSS_Eel, split_idx: int, segments: int) {
    append(&m.eel, MINIBOSS_Eel{})
    new_eel := &m.eel[len(m.eel) - 1]
    new_eel.eel_idx = len(m.eel) - 1

    anim_collections := &APP_global_app.game.animation_collections

    new_eel.bodies = segments - 1
    new_eel.segments = segments
    new_eel.lower_bodies = segments - 2

    new_eel.spacing = 60
    new_eel.segment_damage_radius = 40
    new_eel.segment_damage = 40
    new_eel.shot_cooldown = old_eel.shot_cooldown

    new_eel.rotation_modulation = old_eel.rotation_modulation
    new_eel.rotation_modulation_dir = old_eel.rotation_modulation_dir

    new_eel.body_segments = make([dynamic]MINIBOSS_Eel_Segment, new_eel.segments, new_eel.segments)
    new_eel.enemy_bullets = make([dynamic]Bullet)
    new_eel.shoot_pattern = GUN_shoot_default
    new_eel.shot_dmg = old_eel.shot_dmg

    new_eel.head_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Head])
    new_eel.tail_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Tail])
    new_eel.body_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Body])
    new_eel.joint_anim_man = ANIMATION_create_manager(&anim_collections[.Eel_Joint])

    new_eel.head = old_eel.body_segments[split_idx + 1]
    for i in 0..<new_eel.segments {
        new_eel.body_segments[i] = old_eel.body_segments[split_idx + 1 + i]
        new_eel.body_segments[i].hp /= 2
        new_eel.body_segments[i].hp = max(new_eel.body_segments[i].hp, 1)
    }

    MINIBOSS_mini_eel_history_change(new_eel, old_eel, split_idx)

    MINIBOSS_eel_init_ai(new_eel, &new_eel.ai)
}

MINIBOSS_mini_eel_history_change :: proc(eel: ^MINIBOSS_Eel, old_eel: ^MINIBOSS_Eel, split_idx: int) {
    new_hist_max := 256//int(512.0 * (f32(eel.bodies) / 28.0))
    eel.history = make([dynamic]MINIBOSS_Eel_History_Point, new_hist_max, new_hist_max)

    start_idx := 0 
    finished := false
    found := false
    for !finished && start_idx < old_eel.history_size {
        if vector_dist(old_eel.history[start_idx].position, eel.head.position) <= 10 {
            finished = true
            found = true
            break
        }

        start_idx += 1
    }

    defer if eel.history_size >= new_hist_max do eel.history_size = new_hist_max - 1

    if !found {
        for j in 0..<new_hist_max {
            eel.history[j] = old_eel.history[j]
        }
    
        eel.history[0].dist = 0
        for i in 1..<len(eel.history) {
            prev := eel.history[i-1].position
            curr := eel.history[i].position
    
            eel.history[i].dist = eel.history[i-1].dist + vector_magnitude(curr - prev)
        }
        return
    }

    for j in 0..<new_hist_max {
        if start_idx + j >= old_eel.history_size do break
        eel.history[j] = old_eel.history[start_idx + j]
        if j == 0 do eel.history[j].dist = 0
        else {
            eel.history[j].dist = vector_dist(eel.history[j - 1].position, eel.history[j].position)
        }
    }
    
    
    
    /*tail_dist := f32(eel.bodies) * eel.spacing

    start_idx := old_eel.history_size - 1
    accumulator: f32 = 0.0

    for i := old_eel.history_size - 1; i > 0; i -= 1 {
        d := old_eel.history[i].dist - old_eel.history[i - 1].dist
        accumulator += d

        if accumulator >= tail_dist {
            start_idx = i - 1
            break
        }
    }

    slice_len := old_eel.history_size - start_idx
    eel.history = make([dynamic]MINIBOSS_Eel_History_Point, slice_len, slice_len)

    eel.history[0] = MINIBOSS_Eel_History_Point{
        position = old_eel.history[start_idx].position,
        dist = 0
    }

    for j in 1..<slice_len {
        old := old_eel.history[start_idx + j]
        prev := eel.history[j - 1].position
        dist := vector_magnitude(old.position - prev)

        eel.history[j] = MINIBOSS_Eel_History_Point{
            position = old.position,
            dist = eel.history[j - 1].dist + dist,
        }
    }*/


    //history_max := int(512.0 * (f32(new_eel.bodies) / 28.0))
    //new_eel.history = make([dynamic]MINIBOSS_Eel_History_Point, history_max, history_max)
    //for i in 0..<history_max {
        //if i >= len(old_eel.history) do break

        //new_eel.history[i] = old_eel.history[i]
    //}
}