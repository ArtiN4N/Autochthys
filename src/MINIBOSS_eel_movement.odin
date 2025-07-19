package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"

MINIBOSS_eel_turn_towards :: proc(cur_a, tar_a, turn_sp: f32) -> f32 {
    diff := math.remainder(tar_a - cur_a, 2 * math.PI)

    if abs(diff) <= turn_sp * dt {
        return tar_a
    }

    step: f32
    if diff > 0 do step = turn_sp * dt
    else do step = -turn_sp * dt

    return cur_a + step
}

MINIBOSS_move_eel :: proc(eel: ^MINIBOSS_Eel) {

    eel.rotation_modulation += dt * math.PI * eel.rotation_modulation_dir
    if eel.rotation_modulation > math.PI / 8 {
        eel.rotation_modulation_dir = -1
    } else if eel.rotation_modulation < -math.PI / 8 {
        eel.rotation_modulation_dir = 1
    }

    //temp_head_rotation := eel.head.rotation + dt * math.PI / 2

    //move_dir := eel.move_dir
    //eel.head.rotation = math.atan2(move_dir.x, -move_dir.y)
    //eel.head.rotation += dt * math.PI / 2

    eel.head.rotation = MINIBOSS_eel_turn_towards(eel.head.rotation, eel.ai.target_rot, 6)

    temp_head_rotation := eel.head.rotation + eel.rotation_modulation
    if _, ok := eel.ai.state.(MINIBOSS_Eel_Constrict); ok {
        temp_head_rotation = eel.head.rotation
    }

    move_dir := -FVector{ math.cos(temp_head_rotation + math.PI / 2),  math.sin(temp_head_rotation + math.PI / 2) }

    prev := eel.head.position
    eel.head.position += move_dir * dt * 600//700//400///200//700

    move_dist := vector_magnitude(eel.head.position - prev)
    new_move_dist: f32
    if eel.history_size == 0 {
        new_move_dist = 0
    } else {
        new_move_dist = eel.history[eel.history_size - 1].dist + move_dist
    }

    if eel.history_size < len(eel.history) {
        eel.history[eel.history_size] = MINIBOSS_Eel_History_Point{ eel.head.position, new_move_dist }
        eel.history_size += 1
    } else {
        for i in 1..<len(eel.history) do eel.history[i - 1] = eel.history[i]
        eel.history[len(eel.history) - 1] = MINIBOSS_Eel_History_Point{ eel.head.position, new_move_dist }
    }

    MINIBOSS_eel_update_segment_positions(eel, new_move_dist)
    MINIBOSS_eel_update_segment_rotations(eel)
}

MINIBOSS_eel_update_segment_rotations :: proc(eel: ^MINIBOSS_Eel) {
    for i in 0..<eel.segments {
        next: FVector
        if i == 0 do next = eel.head.position
        else do next = eel.body_segments[i - 1].position
        curr := eel.body_segments[i].position

        dp := next - curr

        eel.body_segments[i].rotation = math.atan2(dp.y, dp.x) + math.PI / 2
    }
}

MINIBOSS_eel_update_segment_positions :: proc(eel: ^MINIBOSS_Eel, new_move_dist: f32) {
    for i in 0..<eel.segments {
        target_dist := new_move_dist - (f32(i + 1) * eel.spacing)

        if target_dist <= 0 {
            eel.body_segments[i].position = eel.history[0].position
            continue
        }

        found := false
        for j in 1..<eel.history_size {
            d1 := eel.history[j - 1].dist
            d2 := eel.history[j].dist

            if d1 <= target_dist && d2 >= target_dist {
                t := (target_dist - d1) / (d2 - d1)
                eel.body_segments[i].position = lin_interp(eel.history[j-1].position, eel.history[j].position, t)
                found = true
                break
            }
        }

        if !found {
            eel.body_segments[i].position = eel.history[eel.history_size - 1].position
        }
    }
}
