package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"
import rand "core:math/rand"

INTERACTION_NPC_DATA :: struct {
    world_room: LEVEL_Room_World_Index,
    tile: IVector,
    anim_manager: ANIMATION_Manager,
    bob_speed: f32,
    bob_delay: f32,
}

INTERACTION_Manager :: struct {
    npc_data: [INTERACTION_NPC_Type]INTERACTION_NPC_DATA,
    timer: f32,
    anim_manager: ANIMATION_Manager,
}

INTERACTION_create_manager :: proc(man: ^INTERACTION_Manager) {
    anim_collections := &APP_global_app.game.animation_collections

    for type in INTERACTION_NPC_Type {
        INTERACTION_NPC_Setup_Procs[type](&man.npc_data[type])
    }

    man.anim_manager = ANIMATION_create_manager(&anim_collections[.Interact])

    man.timer = 0
}

INTERACTION_update :: proc(man: ^INTERACTION_Manager, room: LEVEL_Room_World_Index) {
    man.timer += dt

    for &npc, type in &man.npc_data {
        if room != npc.world_room do continue

        ANIMATION_update_manager(&npc.anim_manager)
    }
}

INTERACTION_event :: proc(man: ^INTERACTION_Manager, room: LEVEL_Room_World_Index, position: FVector) {
    if !rl.IsKeyPressed(.E) do return

    for &npc, type in &man.npc_data {
        
        if room != npc.world_room do continue
        

        npc_pos := LEVEL_convert_coords_to_real_position(npc.tile)
        npc_cir := Circle{npc_pos.x, npc_pos.y, INTERACTION_NPC_RADIUS}
        p_cir := Circle{position.x, position.y, INTERACTION_PLAYER_RADIUS}
        if !circles_collide(npc_cir, p_cir) do continue

        ANIMATION_update_manager(&npc.anim_manager)
        INTERACTION_NPC_Event_Procs[type]()
    }
}

INTERACTION_draw :: proc(man: ^INTERACTION_Manager, room: LEVEL_Room_World_Index, position: FVector) {
    for &npc, type in &man.npc_data {
        if room != npc.world_room do continue

        npc_pos := LEVEL_convert_coords_to_real_position(npc.tile)
        npc_tile_rect := Rect{npc_pos.x - LEVEL_TILE_SIZE / 2, npc_pos.y - LEVEL_TILE_SIZE / 2, LEVEL_TILE_SIZE, LEVEL_TILE_SIZE}
        npc_tile_rect.y += math.sin((man.timer + npc.bob_delay) * npc.bob_speed) * INTERACTION_NPC_BOB_SIZE

        dest_frame := to_rl_rect(ANIMATION_manager_get_dest_frame(&npc.anim_manager, npc_tile_rect))
        src_frame := to_rl_rect(ANIMATION_manager_get_src_frame(&npc.anim_manager))
        dest_origin := ANIMATION_manager_get_dest_origin(&npc.anim_manager, dest_frame)

        tex_sheet := npc.anim_manager.collection.entity_type
        rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, 0, rl.WHITE)

        npc_cir := Circle{npc_pos.x, npc_pos.y, INTERACTION_NPC_RADIUS}
        p_cir := Circle{position.x, position.y, INTERACTION_PLAYER_RADIUS}
        if !circles_collide(npc_cir, p_cir) do continue


        //interact_rect := 

        dest_frame = to_rl_rect(ANIMATION_manager_get_dest_frame(&man.anim_manager, npc_tile_rect))
        src_frame = to_rl_rect(ANIMATION_manager_get_src_frame(&man.anim_manager))
        dest_origin = ANIMATION_manager_get_dest_origin(&man.anim_manager, dest_frame)

        tex_sheet = man.anim_manager.collection.entity_type
        dest_frame.y -= LEVEL_TILE_SIZE / 2
        dest_frame.x += LEVEL_TILE_SIZE / 2
        rl.DrawTexturePro(TEXTURE_get_global_sheet(tex_sheet)^, src_frame, dest_frame, dest_origin, 0, rl.WHITE)
    }
}