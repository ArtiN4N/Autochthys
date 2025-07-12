package src

import fmt "core:fmt"


INTERACTION_savepoint_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data) {
    man.set_dialouge_array = DIALOUGE_global_finder_savepoint(data)
    man.set_dialouge_sound = .Man_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Savepoint].anim_manager

    TRANSITION_set(.Game, .Savepoint)
}

INTERACTION_tutorial_npc_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data) {
    man.set_dialouge_array = DIALOUGE_global_finder_tutorial(data)
    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Tutorial].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_fishemans_npc_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data) {
    man.set_dialouge_array = &DIALOUGE_TUTORIAL_MEETING1
    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Fishemans].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}