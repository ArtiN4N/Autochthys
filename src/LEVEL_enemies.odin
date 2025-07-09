package src

LEVEL_MIN_ENEMIES :: 4
LEVEL_ENEMIES_AGGRESSION_SPAWN_FACTOR :: 1

LEVEL_aggression_to_num_enemies :: proc(a: int) -> int {
    return LEVEL_MIN_ENEMIES + a * LEVEL_ENEMIES_AGGRESSION_SPAWN_FACTOR
}