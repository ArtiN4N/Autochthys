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

INTERACTION_NPC_Type :: enum { Tutorial, Fishemans, Savepoint, }

INTERACTION_NPC_Event_Procs: [INTERACTION_NPC_Type]INTERACTION_proc_event = {
    .Tutorial = INTERACTION_tutorial_npc_event,
    .Fishemans = INTERACTION_fishemans_npc_event,
    .Savepoint = INTERACTION_savepoint_event,
}

INTERACTION_NPC_Setup_Procs: [INTERACTION_NPC_Type]INTERACTION_proc_setup = {
    .Tutorial = INTERACTION_tutorial_npc_setup,
    .Fishemans = INTERACTION_fishemans_npc_setup,
    .Savepoint = INTERACTION_savepoint_setup,
}

INTERACTION_proc_setup :: proc(data: ^INTERACTION_NPC_Data)
INTERACTION_proc_event :: proc(man: ^INTERACTION_Manager, data: ^INTERACTION_NPC_Data)