package src

import fmt "core:fmt"
import rand "core:math/rand"

INTERACTION_give_item :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    item_man := &APP_global_app.game.item_manager
    item_id := INTERACTION_to_item_id(type)

    if data.talked_to == 0 do man.set_dialouge_give_item = true

    // use item_id to find dialouge text and animation
    man.set_dialouge_array = ITEM_global_dialouge_finder(item_id, data.talked_to)
    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[ITEM_id_to_interaction(item_id)].anim_manager
    man.set_dialouge_item_anim_manager = &item_man.anim_managers[item_id]

    if data.talked_to == 0 do ITEM_global_give_item(item_id, 1)
    TRANSITION_set(.Game, .Dialouge)
}


INTERACTION_savepoint_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    man.set_dialouge_array = DIALOUGE_global_finder_savepoint(data)
    man.set_dialouge_sound = .Man_Voice
    //man.set_dialouge_anim_manager = &man.npc_data[.Savepoint].anim_manager

    TRANSITION_set(.Game, .Savepoint)
}

INTERACTION_tutorial_npc_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    man.set_dialouge_array = DIALOUGE_global_finder_tutorial(data)
    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Tutorial].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}

INTERACTION_cgiver_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    item_man := &APP_global_app.game.item_manager
    item_id := ITEM_type.Clip

    if data.talked_to == 0 {
        man.set_dialouge_give_item = true
        man.set_dialouge_array = &ITEM_DIALOUGE_GET_CHOICES[item_id]
    } else {
        choice := data.talked_to - 1
        if choice >= len(ITEM_EXHAUST_DIALOUGE_CLIP) do choice = rand.int_max(len(ITEM_EXHAUST_DIALOUGE_CLIP))
        man.set_dialouge_array = &ITEM_EXHAUST_DIALOUGE_CLIP[choice]
    }

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Clip_Giver].anim_manager
    man.set_dialouge_item_anim_manager = &item_man.anim_managers[item_id]

    if data.talked_to == 0 do ITEM_global_give_item(item_id, 1)
    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_wgiver_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    item_man := &APP_global_app.game.item_manager
    item_id := ITEM_type.Wallet

    if data.talked_to == 0 {
        man.set_dialouge_give_item = true
        man.set_dialouge_array = &ITEM_DIALOUGE_GET_CHOICES[item_id]
    } else {
        choice := data.talked_to - 1
        if choice >= len(ITEM_EXHAUST_DIALOUGE_WALLET) do choice = rand.int_max(len(ITEM_EXHAUST_DIALOUGE_WALLET))
        man.set_dialouge_array = &ITEM_EXHAUST_DIALOUGE_WALLET[choice]
    }

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Wallet_Giver].anim_manager
    man.set_dialouge_item_anim_manager = &item_man.anim_managers[item_id]

    if data.talked_to == 0 do ITEM_global_give_item(item_id, 1)
    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_badass_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    choice := data.talked_to
    if choice >= len(DIALOUGE_BADASS) do choice = rand.int_max(len(DIALOUGE_BADASS))
    man.set_dialouge_array = &DIALOUGE_BADASS[choice]

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Badass].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_dudebro_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    choice := data.talked_to
    if choice >= len(DIALOUGE_DUDEBRO) do choice = rand.int_max(len(DIALOUGE_DUDEBRO))
    man.set_dialouge_array = &DIALOUGE_DUDEBRO[choice]

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Helpful_Dude].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_house_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    item_man := &APP_global_app.game.item_manager
    item_id := ITEM_type.Housekey

    if data.talked_to == 0 {
        man.set_dialouge_give_item = true
        man.set_dialouge_array = &ITEM_DIALOUGE_GET_CHOICES[item_id]
    } else {
        choice := data.talked_to - 1
        if choice >= len(ITEM_EXHAUST_DIALOUGE_HOUSEKEY) do choice = rand.int_max(len(ITEM_EXHAUST_DIALOUGE_HOUSEKEY))
        man.set_dialouge_array = &ITEM_EXHAUST_DIALOUGE_HOUSEKEY[choice]
    }

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.House_Key_Giver].anim_manager
    man.set_dialouge_item_anim_manager = &item_man.anim_managers[item_id]

    if data.talked_to == 0 do ITEM_global_give_item(item_id, 1)
    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_dog_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    choice := data.talked_to
    if choice >= len(DIALOUGE_DOG) do choice = rand.int_max(len(DIALOUGE_DOG))
    man.set_dialouge_array = &DIALOUGE_DOG[choice]

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Lost_Dog].anim_manager
    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_drum_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    choice := data.talked_to
    if choice >= len(DIALOUGE_DRUMMER) do choice = rand.int_max(len(DIALOUGE_DRUMMER))
    man.set_dialouge_array = &DIALOUGE_DRUMMER[choice]

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Drummer].anim_manager

    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_imposer_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    item_man := &APP_global_app.game.item_manager
    item_id := ITEM_type.Suskey

    if data.talked_to == 0 {
        man.set_dialouge_give_item = true
        man.set_dialouge_array = &ITEM_DIALOUGE_GET_CHOICES[item_id]
    } else {
        choice := data.talked_to - 1
        if choice >= len(ITEM_EXHAUST_DIALOUGE_IMPOSER) do choice = rand.int_max(len(ITEM_EXHAUST_DIALOUGE_IMPOSER))
        man.set_dialouge_array = &ITEM_EXHAUST_DIALOUGE_IMPOSER[choice]
    }

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Imposer].anim_manager
    man.set_dialouge_item_anim_manager = &item_man.anim_managers[item_id]

    if data.talked_to == 0 do ITEM_global_give_item(item_id, 1)
    TRANSITION_set(.Game, .Dialouge)
}
INTERACTION_charm_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    item_man := &APP_global_app.game.item_manager
    item_id := ITEM_type.Charm

    if data.talked_to == 0 {
        man.set_dialouge_give_item = true
        man.set_dialouge_array = &ITEM_DIALOUGE_GET_CHOICES[item_id]
    } else {
        choice := data.talked_to - 1
        if choice >= len(ITEM_EXHAUST_DIALOUGE_CHARM) do choice = rand.int_max(len(ITEM_EXHAUST_DIALOUGE_CHARM))
        man.set_dialouge_array = &ITEM_EXHAUST_DIALOUGE_CHARM[choice]
    }

    man.set_dialouge_sound = .Tutorial_Voice
    man.set_dialouge_anim_manager = &man.npc_data[.Charm_Giver].anim_manager
    man.set_dialouge_item_anim_manager = &item_man.anim_managers[item_id]

    if data.talked_to == 0 do ITEM_global_give_item(item_id, 1)
    TRANSITION_set(.Game, .Dialouge)
}