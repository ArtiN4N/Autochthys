package src

import math "core:math"
import rand "core:math/rand"

INTERACTION_give_item_setup :: proc(data: ^INTERACTION_NPC_Data, type: INTERACTION_NPC_Type) {
    anim_collections := &APP_global_app.game.animation_collections

    item_id := INTERACTION_to_item_id(type)
    item_man := &APP_global_app.game.item_manager

    // use item_id to find out where its spawned
    ITEM_global_set_giver_to_room_and_tile(.KeyA, 4, {1, 14})
    ITEM_global_set_giver_to_room_and_tile(.KeyB, 4, {2, 14})
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