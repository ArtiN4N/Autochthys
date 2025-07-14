package src

import rl "vendor:raylib"
import fmt "core:fmt"
import strings "core:strings"

ITEM_type :: enum { NO_ITEM, KeyA, KeyB }
@(rodata)
ITEM_type_to_name := [ITEM_type]string{
    .NO_ITEM = "Corrupted",
    .KeyA = "Boss Key A",
    .KeyB = "Boss Key B"
}

ITEM_anim_manager_set :: [ITEM_type]ANIMATION_Manager

ITEM_Manager :: struct {
    anim_managers: ITEM_anim_manager_set,
    key_items: [ITEM_type]int,
    items: [ITEM_type]int,
    giver_rooms: [ITEM_type]LEVEL_Room_World_Index,
    giver_tiles: [ITEM_type]FVector,
}

ITEM_global_giver_room_tile :: proc(type: ITEM_type) -> (LEVEL_Room_World_Index, FVector) {
    item_man := &APP_global_app.game.item_manager

    return item_man.giver_rooms[type], item_man.giver_tiles[type]
}

ITEM_global_set_giver_to_room_and_tile :: proc(type: ITEM_type, room: LEVEL_Room_World_Index, tile: FVector) {
    item_man := &APP_global_app.game.item_manager

    item_man.giver_rooms[type] = room
    item_man.giver_tiles[type] = tile
}

ITEM_is_key_item :: proc(item: ITEM_type) -> bool {
    is_key := item == .KeyA || item == .KeyB

    return is_key
}

ITEM_create_manager :: proc(m: ^ITEM_Manager) {
    ITEM_create_anim_managers(&m.anim_managers)

    for t in ITEM_type {
        m.key_items[t] = 0
        m.key_items[t] = 0
    }
}

ITEM_global_give_item :: proc(item: ITEM_type, amt: int) {
    if ITEM_is_key_item(item) {
        APP_global_app.game.item_manager.key_items[item] += amt
    } else {
        APP_global_app.game.item_manager.items[item] += amt
    }

    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)
    nbuilder := strings.builder_make()

    fmt.sbprintf(&nbuilder, "Aquired %v %v", amt, ITEM_type_to_name[item])
    NOTIFICATION_global_add(strings.to_string(nbuilder), FVector{10, rh - 10 - 24}, EXP_COLOR, FVector{0, -1})
    strings.builder_destroy(&nbuilder)
}

ITEM_global_take_item :: proc(item: ITEM_type, amt: int) {
    if ITEM_is_key_item(item) {
        APP_global_app.game.item_manager.key_items[item] -= amt
        if APP_global_app.game.item_manager.key_items[item] < 0 {
            APP_global_app.game.item_manager.key_items[item] = 0
        }
    } else {
        APP_global_app.game.item_manager.items[item] -= amt
        if APP_global_app.game.item_manager.items[item] < 0 {
            APP_global_app.game.item_manager.items[item] = 0
        }
    }

    _rw, _rh := APP_get_global_render_size()
    rw, rh := f32(_rw), f32(_rh)
    nbuilder := strings.builder_make()

    fmt.sbprintf(&nbuilder, "Consumed %v %v", amt, ITEM_type_to_name[item])
    NOTIFICATION_global_add(strings.to_string(nbuilder), FVector{10, rh - 10 - 24}, DMG_COLOR, FVector{0, -1})
    strings.builder_destroy(&nbuilder)
}

ITEM_create_anim_managers :: proc(item_anim_set: ^ITEM_anim_manager_set) {
    anim_collections := &APP_global_app.game.animation_collections

    for &aman, type in item_anim_set {
        item_anim_set[type] = ANIMATION_create_manager(&anim_collections[ITEM_to_animation_collection_type(type)])
    }
}

ITEM_to_animation_collection_type :: proc(itype: ITEM_type) -> ANIMATION_Entity_Type {
    switch itype {
    case .KeyA:
        return .ITEM_Key
    case .KeyB:
        return .ITEM_Key
    case .NO_ITEM:
    }

    return .Koi
}

ITEM_to_giver_animation_collection_type :: proc(itype: ITEM_type) -> ANIMATION_Entity_Type {
    return .ITEM_Giver
}

INTERACTION_to_item_id :: proc(itype: INTERACTION_NPC_Type) -> ITEM_type {
    #partial switch itype {
    case .KeyA_Giver:
        return .KeyA
    case .KeyB_Giver:
        return .KeyB
    }
    return .NO_ITEM
}

ITEM_id_to_interaction :: proc(type: ITEM_type) -> INTERACTION_NPC_Type {
    #partial switch type {
    case .KeyA:
        return .KeyA_Giver
    case .KeyB:
        return .KeyB_Giver
    }
    return .KeyA_Giver
}