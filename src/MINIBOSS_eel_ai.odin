package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"
import rand "core:math/rand"

MINIBOSS_Eel_State :: union {
    MINIBOSS_Eel_Hide,
    MINIBOSS_Eel_Charge,
    MINIBOSS_Eel_Charge_Switch,
    MINIBOSS_Eel_Constrict,
}

// head goes offscreen. the moment the head reaches the hide target, it starts a new attack
MINIBOSS_Eel_Hide :: struct {
    chosen_target: FVector,
}
// picks a position at the end of a line between it and the player
// charges through that position past the map
MINIBOSS_Eel_Charge :: struct {
    chosen_target: FVector,
}
// charges to the playter, but before it reaches, suddnely change direction
MINIBOSS_Eel_Charge_Switch :: struct {
    rot_offset: f32,
}
// circle the map, firing bullets
MINIBOSS_Eel_Constrict :: struct {
    start_pos: FVector,
    reached_start: bool,
    reachedd_halfway: bool,
    start_dir: FVector,
}

MINIBOSS_Eel_AI :: struct {
    state: MINIBOSS_Eel_State,
    finished_state: bool,

    target_rot: f32,
}

MINIBOSS_eel_ai_hide_random_position :: proc() -> FVector {
    desired_dist: f32 = 600
    random_dir := vector_normalize(FVector{ 2 * rand.float32() - 0.5, 2 * rand.float32() - 0.5 })

    //fmt.printfln("hiding at %v", FVector{ 768 / 2, 768 / 2 } + random_dir * desired_dist)

    return FVector{ 768 / 2, 768 / 2 } + random_dir * desired_dist
}

MINIBOSS_eel_ai_charge_proc :: proc(eel: ^MINIBOSS_Eel, ai: ^MINIBOSS_Eel_AI) {
    target := ai.state.(MINIBOSS_Eel_Charge).chosen_target
    face_dir := target - eel.head.position
    ai.target_rot = math.atan2(face_dir.x, -face_dir.y)

    if vector_dist(eel.head.position, target) < 30 do ai.finished_state = true
}

MINIBOSS_eel_ai_hide_proc :: proc(eel: ^MINIBOSS_Eel, ai: ^MINIBOSS_Eel_AI) {
    target := ai.state.(MINIBOSS_Eel_Hide).chosen_target
    face_dir := target - eel.head.position
    ai.target_rot = math.atan2(face_dir.x, -face_dir.y)

    if vector_dist(eel.head.position, target) < 30 do ai.finished_state = true
}

MINIBOSS_eel_init_ai :: proc(eel: ^MINIBOSS_Eel, ai: ^MINIBOSS_Eel_AI) {
    ai.target_rot = eel.head.rotation

    ai.state = MINIBOSS_Eel_Hide{MINIBOSS_eel_ai_hide_random_position()}
    ai.finished_state = false
}

MINIBOSS_eel_ai_start_charge :: proc(eel: ^MINIBOSS_Eel, ai: ^MINIBOSS_Eel_AI) -> (charge: MINIBOSS_Eel_Charge) {
    startpos := eel.head.position
    midpos := APP_global_app.game.player.position
    endpos := midpos + vector_normalize(midpos - startpos) * 300

    charge.chosen_target = endpos
    return
}

MINIBOSS_eel_ai_start_constrict :: proc(eel: ^MINIBOSS_Eel, ai: ^MINIBOSS_Eel_AI) -> (constrict: MINIBOSS_Eel_Constrict) {
    desired_dist: f32 = 350
    random_dir := vector_normalize(FVector{ 2 * rand.float32() - 0.5, 2 * rand.float32() - 0.5 })
    constrict.start_dir = random_dir

    constrict.reached_start = false
    constrict.reachedd_halfway = false
    constrict.start_pos = FVector{ 768 / 2, 768 / 2 } + random_dir * desired_dist

    return
}

MINIBOSS_eel_ai_constrict_proc :: proc(eel: ^MINIBOSS_Eel, ai: ^MINIBOSS_Eel_AI) {
    cons := &ai.state.(MINIBOSS_Eel_Constrict)

    if !cons.reached_start {
        if vector_dist(eel.head.position, cons.start_pos) < 30 do cons.reached_start = true
        else {
            face_dir := cons.start_pos - eel.head.position
            ai.target_rot = math.atan2(face_dir.x, -face_dir.y)
            return
        }
    }

    if vector_dist(eel.head.position, cons.start_pos) > 100 && !cons.reachedd_halfway do cons.reachedd_halfway = true
    if cons.reachedd_halfway && vector_dist(eel.head.position, cons.start_pos) < 30 do ai.finished_state = true
    
    dp := eel.head.position - FVector{ 768 / 2, 768 / 2 }
    cur_angle := math.atan2(dp.y, dp.x)
    next_angle := cur_angle + (math.PI * 2) / 180
    next_pos := FVector{ 768 / 2, 768 / 2 } + {math.cos(next_angle), math.sin(next_angle)} * 350

    face_dir := next_pos - eel.head.position
    ai.target_rot = math.atan2(face_dir.x, -face_dir.y)
}

MINIBOSS_eel_ai_proc :: proc(eel: ^MINIBOSS_Eel, ai: ^MINIBOSS_Eel_AI) {
    switch &t in &ai.state {
    case MINIBOSS_Eel_Hide:
        MINIBOSS_eel_ai_hide_proc(eel, ai)
    case MINIBOSS_Eel_Charge:
        MINIBOSS_eel_ai_charge_proc(eel, ai)
    case MINIBOSS_Eel_Charge_Switch:
    case MINIBOSS_Eel_Constrict:
        MINIBOSS_eel_ai_constrict_proc(eel, ai)
    }


    if ai.finished_state {
        switch &t in &ai.state {
        case MINIBOSS_Eel_Hide:
            // pick random state

            choice := rand.float32()
            if choice <= 0.1 do ai.state = MINIBOSS_eel_ai_start_constrict(eel, ai)
            else do ai.state = MINIBOSS_eel_ai_start_charge(eel, ai)

        case MINIBOSS_Eel_Charge:
            ai.state = MINIBOSS_Eel_Hide{MINIBOSS_eel_ai_hide_random_position()}
        case MINIBOSS_Eel_Charge_Switch:
            ai.state = MINIBOSS_Eel_Hide{MINIBOSS_eel_ai_hide_random_position()}
        case MINIBOSS_Eel_Constrict:
            ai.state = MINIBOSS_Eel_Hide{MINIBOSS_eel_ai_hide_random_position()}
        }

        ai.finished_state = false
    }
}