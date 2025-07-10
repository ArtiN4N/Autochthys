package src

import rl "vendor:raylib"

// A ANIMATION_Collection of animations
// Stores the data for all animations a specific type of entity uses,
// so that each entity instance doesnt need to store redundant data
ANIMATION_Collection :: struct {
    // maps an animation string key to its data
    animations: [ANIMATION_Tag]ANIMATION_Data,

    // the multiplier of each animation frame's size to draw on the screen
    // should match the default size of the entity
    sheet_scale: f32,

    // which entity this ANIMATION_Collection represents
    entity_type: ANIMATION_Entity_Type,
}

ANIMATION_create_collection :: proc(
    scale: f32, type: ANIMATION_Entity_Type,
) -> (c: ANIMATION_Collection) {
    c.sheet_scale = scale
    c.entity_type = type


    return c
}
 
ANIMATION_destroy_collection :: proc(c: ^ANIMATION_Collection) {
}