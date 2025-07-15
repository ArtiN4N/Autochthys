package src

import math "core:math"
import rand "core:math/rand"

INTERACTION_give_item_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections

    item_id := INTERACTION_to_item_id(type)
    item_man := &APP_global_app.game.item_manager

    // use item_id to find out where its spawned
    data.world_room, data.tile = ITEM_global_giver_room_tile(item_id)

    // use type to find item animation
    data.anim_manager = ANIMATION_create_manager(&anim_collections[ITEM_to_giver_animation_collection_type(item_id)])
}

INTERACTION_savepoint_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections

    data.world_room = 4
    data.tile = FVector{7.5, 7.5}
    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Savepoint])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = 1
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_tutorial_npc_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections

    data.world_room = 4
    data.tile = FVector{2,2}
    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Tutorial])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_cgiver_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Clip_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_wgiver_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Wallet_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_badass_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Badass_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_dudebro_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Dudebro_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_house_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.House_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_dog_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Dog_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_drummer_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Drummer_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_imposer_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Imposer_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}

INTERACTION_charm_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections
    iman := &APP_global_app.game.interaction_manager

    room_choice := rand.int_max(len(iman.avail_spawn_rooms))
    data.world_room = iman.avail_spawn_rooms[room_choice]
    unordered_remove(&iman.avail_spawn_rooms, room_choice)

    level_t := APP_global_app.game.current_world.rooms[data.world_room].tag
    col := &APP_global_app.game.level_manager.levels[level_t]

    data.tile = LEVEL_get_non_col_tile(col)

    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Charm_npc])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
    data.bob_size = INTERACTION_NPC_BOB_SIZE
}