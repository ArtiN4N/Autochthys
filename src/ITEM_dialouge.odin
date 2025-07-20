package src

import rand "core:math/rand"

@(rodata)
ITEM_DIALOUGE_GET_CHOICES := #partial [ITEM_type][]string{
    .NO_ITEM = {"... How'd you get this ...", "what the hell man"},
    .KeyA = {
        "Thats right its @blue<me>.",
        "Normally I dont  ^But for you, I make  exception",
        "Youre looking  key?^...",
        "Since your such loyal fan^I'll give  to you",
        "(*) Boss key A aquired!",
    },
    .KeyB = {
        "Thats right its @blue<me>.",
        "Normally I dont  ^But for you, I make  exception",
        "Youre looking  key?^...",
        "Since your such loyal fan^I'll give  to you",
        "(*) Boss key B aquired!",
    },

    .Charm = {
        "H-hi...^Whats...",
        "AHHHHH^AAAAAHHHH^OKAY OKAY",
        "I GET IT! YOU CAN HAVE IT!^JUST DONT HURT MEEEE!!!",
        "(*) Special Charm aquired!^It fills you with the power of foresight!",
    },
    .Suskey = {
        "...",
        "...^...",
        "(*) Sus Key aquired!^...It doesn't seem like the key your looking for...",
    },
    .Housekey = {
        "Ah yes, one moment^Lets see here, 40 lbs of tiger meat, right?^...",
        "...^...w-wait...",
        "...but^...hey!...uh...",
        "...^...^fine...",
        "(*) House Key aquired!^...It doesn't seem like the key your looking for...",
    },
    .Wallet = {
        "Finally! 5 Dollars!^It may have taken me my whole life to aquire this...",
        "But finally! Finally I can...",
        "W-wait... hey...^HEY!! GIVE THAT BACK!!!",
        "(*) Some guy's wallet aquired!",
    },
    .Clip = {
        "...^...",
        "I see...^Yes, I see...",
        "You, you sir...^You are, uh...^You are, well, uh...",
        "The chosen one! Yes thats right!^I have something for you",
        "This... Uh, this...^Old bullet clip...^Uh, yea! This is for the, uh, chosen one!",
        "Your welcome.^Now, you, uh, have no reason to rob me!^ahahahahahahahha",
        "(*) Rusty bullet clip aquired!",
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