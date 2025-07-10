package src

import math "core:math"
import rand "core:math/rand"

INTERACTION_tutorial_npc_setup :: proc(data: ^INTERACTION_NPC_Data) {
    anim_collections := &APP_global_app.game.animation_collections

    data.world_room = 4
    data.tile = IVector{2,2}
    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Tutorial])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
}
INTERACTION_fishemans_npc_setup :: proc(data: ^INTERACTION_NPC_Data) {
    anim_collections := &APP_global_app.game.animation_collections

    data.world_room = 4
    data.tile = IVector{13,13}
    data.anim_manager = ANIMATION_create_manager(&anim_collections[.Fishemans])

    data.bob_delay = rand.float32() * math.PI
    data.bob_speed = rand.choice(INTERACTION_NPC_bob_speed_choices)
}