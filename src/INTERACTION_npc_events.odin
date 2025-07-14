package src

import fmt "core:fmt"

INTERACTION_give_item :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    item_man := &APP_global_app.game.item_manager
    item_id := INTERACTION_to_item_id(type)

    if data.talked_to == 0 do man.set_dialouge_give_item = true

    // use item_id to find dialouge text and animation
    man.set_dialouge_array = ITEM_global_dialouge_finder(item_id, data.talked_to)
    man.set_dialouge_sound = .Man_Voice
    man.set_dialouge_anim_manager = &man.npc_data[ITEM_id_to_interaction(item_id)].anim_manager
    man.set_dialouge_item_anim_manager = &item_man.anim_managers[item_id]

    if data.talked_to == 0 do ITEM_global_give_item(item_id, 1)
    TRANSITION_set(.Game, .Dialouge)
}


INTERACTION_savepoint_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    man.set_dialouge_array = DIALOUGE_global_finder_savepoint(data)
    man.set_dialouge_sound = .Man_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Savepoint].anim_manager

    TRANSITION_set(.Game, .Savepoint)
}

INTERACTION_tutorial_npc_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    man.set_dialouge_array = DIALOUGE_global_finder_tutorial(data)
    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Tutorial].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}