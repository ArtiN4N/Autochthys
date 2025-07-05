package src

import fmt "core:fmt"
import rand "core:math/rand"

STATS_Player :: struct {
    level: int,
    experience: f32
}

// should be reworked for an exponential feel
STATS_level_up_equation :: proc(level: int) -> (required_exp: f32) {
    return STATS_BASE_LEVEL_UP_EXP + f32(level) * STATS_LEVEL_UP_EXP_FACTOR
}

STATS_collect_exp :: proc(stats: ^STATS_Player, exp: f32) {
    stats.experience += exp + (rand.float32() - 0.5) * exp
    required := STATS_level_up_equation(stats.level)

    if stats.experience >= required {
        stats.level += 1
        stats.experience -= required

        SOUND_global_fx_manager_play_tag(.Player_Levelup)
    }
}