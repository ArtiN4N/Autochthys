package src

INTERACTION_NPC_RADIUS :: LEVEL_TILE_SIZE / 2
INTERACTION_PLAYER_RADIUS :: LEVEL_TILE_SIZE / 4

// fun fact -- this is not for an npc called bob
// its just the npcs bobbing up and down
INTERACTION_NPC_BOB_SIZE :: 12

@(rodata)
INTERACTION_NPC_bob_speed_choices := []f32{
    0.5, 0.75, 1, 2, 3, 4
}

INTERACTION_NPC_Type :: enum {
    Tutorial, //Savepoint,
    KeyA_Giver, KeyB_Giver,

    Clip_Giver,
    Wallet_Giver,
    Badass,

    Helpful_Dude,
    House_Key_Giver,
    Lost_Dog,

    Drummer,
    Imposer,
    Charm_Giver,
}

INTERACTION_NPC_Event_Procs: [INTERACTION_NPC_Type]INTERACTION_proc_event = {
    .Tutorial = INTERACTION_tutorial_npc_event,
    //.Savepoint = INTERACTION_savepoint_event,

    .KeyA_Giver = INTERACTION_give_item,
    .KeyB_Giver = INTERACTION_give_item,


    .Clip_Giver = INTERACTION_cgiver_event,
    .Wallet_Giver = INTERACTION_wgiver_event,
    .Badass = INTERACTION_badass_event,
    .Helpful_Dude = INTERACTION_dudebro_event,
    .House_Key_Giver = INTERACTION_house_event,
    .Lost_Dog = INTERACTION_dog_event,
    .Drummer = INTERACTION_drum_event,
    .Imposer = INTERACTION_imposer_event,
    .Charm_Giver = INTERACTION_charm_event,
}

INTERACTION_NPC_Setup_Procs: [INTERACTION_NPC_Type]INTERACTION_proc_setup = {
    .Tutorial = INTERACTION_tutorial_npc_setup,
    //.Savepoint = INTERACTION_savepoint_setup,

    .KeyA_Giver = INTERACTION_give_item_setup,
    .KeyB_Giver = INTERACTION_give_item_setup,

    .Clip_Giver = INTERACTION_cgiver_setup,
    .Wallet_Giver = INTERACTION_wgiver_setup,
    .Badass = INTERACTION_badass_setup,
    .Helpful_Dude = INTERACTION_dudebro_setup,
    .House_Key_Giver = INTERACTION_house_setup,
    .Lost_Dog = INTERACTION_dog_setup,
    .Drummer = INTERACTION_drummer_setup,
    .Imposer = INTERACTION_imposer_setup,
    .Charm_Giver = INTERACTION_charm_setup,
}

INTERACTION_proc_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type)
INTERACTION_proc_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type)