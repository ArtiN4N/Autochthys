package src

import rand "core:math/rand"

@(rodata)
DIALOUGE_SAVEPOINT_NORMAL_CHOICES := [][]string{
    {"(*) ...",},
    {"(*) a resting point)",},
    {"(*) a low hum^permeates the water",},
    {"(*) ever so slightly^it glows",},
    {"(*) difficult to see",},
    {"(*) you feel a chill^run down your spine",},
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