package src

import fmt "core:fmt"

INTERACTION_tutorial_npc_event :: proc(man: ^INTERACTION_Manager) {
    man.set_dialouge_array = &DIALOUGE_TUTORAIL_MEETING1
    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Tutorial].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_fishemans_npc_event :: proc(man: ^INTERACTION_Manager) {
    man.set_dialouge_array = &DIALOUGE_TUTORAIL_MEETING1
    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Fishemans].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}