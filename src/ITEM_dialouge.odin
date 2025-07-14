package src

import rand "core:math/rand"

@(rodata)
ITEM_DIALOUGE_GET_CHOICES := [ITEM_type][]string{
    .NO_ITEM = {"... How'd you get this ...", "what the hell man"},
    .KeyA = {
        "Thats right its @blue<me>.",
        "Normally I dont  ^But for you, I make  exception",
        "Youre looking  key?^...",
        "Since your such loyal fan^I'll give  to you",
        "(*) Boss key A aquired",
    },
    .KeyB = {
        "Thats right its @blue<me>.",
        "Normally I dont  ^But for you, I make  exception",
        "Youre looking  key?^...",
        "Since your such loyal fan^I'll give  to you",
        "(*) Boss key B aquired",
    },
}

@(rodata)
DIALOUGE_ITEM_GIVER_CHOICES := [][]string{
    {"Here to admire me are?^Take  in buddy",},
    {"My fan  are so loyal...^TO think  endager yourself like  just to see me....",},
    {"Sorry, no autographs^Its not because  dont know how to spell", "...", "Its   !"},
    {"To think even freak like you  me^This is why they pay me the   ",},
}

ITEM_global_dialouge_finder :: proc(type: ITEM_type, talked_to: int) -> ^[]string {
    if talked_to == 0 {
        return &ITEM_DIALOUGE_GET_CHOICES[type]
    }

    return &DIALOUGE_ITEM_GIVER_CHOICES[rand.int_max(len(DIALOUGE_ITEM_GIVER_CHOICES))]
}