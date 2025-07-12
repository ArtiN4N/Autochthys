package src

import rand "core:math/rand"

@(rodata)
DIALOUGE_SAVEPOINT_NORMAL_CHOICES := [][]string{
    {"(*) ...",},
    {"(*) ...",},
    {"(*) ...",},
    {"(*) ...",},
    {"(*) ...",},
    {"(*) ...",},
    {"(*) ...",},
    {"(*) ...",},
}

DIALOUGE_global_finder_savepoint :: proc(data: ^INTERACTION_NPC_Data) -> ^[]string {
    app := &APP_global_app

    i := rand.int_max(len(DIALOUGE_SAVEPOINT_NORMAL_CHOICES))

    return &DIALOUGE_SAVEPOINT_NORMAL_CHOICES[i]
}