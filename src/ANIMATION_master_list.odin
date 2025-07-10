package src

import rl "vendor:raylib"

// a master list that stores all animation data for all entity types
ANIMATION_Master_Collections :: [ANIMATION_Entity_Type]ANIMATION_Collection

ANIMATION_add_data_to_master_list :: proc(list: ^ANIMATION_Master_Collections, type: ANIMATION_Entity_Type, data: ANIMATION_Data) {
    collection: ^ANIMATION_Collection = &list[type]
    animation_map: ^map[string]ANIMATION_Data = &collection.animations

    key := data.name

    animation_map[key] = data
}

// deletes one collection -- collections contain an allocated map of animations that must be freed
ANIMATION_remove_collection_from_master_list :: proc(list: ^ANIMATION_Master_Collections, type: ANIMATION_Entity_Type) {
    collection: ^ANIMATION_Collection = &list[type]
    ANIMATION_destroy_collection(collection)
}

// removes all collections -- collections contain an allocated map of animations that must be freed
ANIMATION_wipe_collections_from_master_list :: proc(list: ^ANIMATION_Master_Collections) {
    for &collection, type in list {
        ANIMATION_destroy_collection(&collection)
    }
}

ANIMATION_add_collections_from_master_list :: proc(list: ^ANIMATION_Master_Collections) {
    ANIMATION_create_koi_collections(list)
    ANIMATION_create_minnow_collections(list)
}