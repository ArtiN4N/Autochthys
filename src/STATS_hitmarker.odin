package src

import rl "vendor:raylib"
import math "core:math"
import rand "core:math/rand"

STATS_Hitmarker :: struct {
    position, velocity: FVector,
    elapsed: f32,
    length: f32,
    dmg: f32,
}

STATS_HITMARKER_LENGTH :: 1
STATS_HITMARKER_SPEED :: 32
STATS_create_hitmarker :: proc(pos: FVector, dmg: f32) -> (h: STATS_Hitmarker) {
    h.position = pos

    rand_deg := rand.float32() * math.PI / 2 - math.PI / 2 - math.PI / 4
    rand_dir := FVector{ math.cos(rand_deg), math.sin(rand_deg) }
    h.velocity = rand_dir * STATS_HITMARKER_SPEED

    h.elapsed = 0
    h.length = STATS_HITMARKER_LENGTH

    h.dmg = dmg

    return h
}

STATS_update_hitmarker :: proc(h: ^STATS_Hitmarker) -> (kill: bool) {
    dt := rl.GetFrameTime()

    kill = false
    h.elapsed += dt
    if h.elapsed >= h.length {
        kill = true
        return kill
    }

    h.position += h.velocity * dt

    return kill
}

STATS_draw_hitmarker :: proc(h: ^STATS_Hitmarker) {
    col: rl.Color
    if h.dmg < 10 { col = HITMARKER_1_COLOR }
    else if h.dmg < 50 { col = HITMARKER_2_COLOR }
    else if h.dmg < 100 { col = HITMARKER_3_COLOR }
    else if h.dmg < 500 { col = HITMARKER_4_COLOR }
    else { col = HITMARKER_5_COLOR }

    col.a = u8(255 * (h.length - h.elapsed / h.length))

    font := APP_get_global_default_font()
    rl.DrawTextEx(font^, rl.TextFormat("%d", int(h.dmg)), h.position, 20, 2, col)
}

STATS_update_and_check_hitmarkers :: proc(list: ^[dynamic]STATS_Hitmarker) {
    i := 0
    for i < len(list) && i >= 0 {
        h := &list[i]
        kill := STATS_update_hitmarker(h)
        if kill {
            unordered_remove(list, i)
            continue
        }

        i += 1
    }
}