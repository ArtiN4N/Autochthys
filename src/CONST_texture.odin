package src

import rl "vendor:raylib"

ANIMATION_Entity_Type :: enum {
    Koi,
    Koi_tail,
    Koi_fin,

    Minnow,
    Minnow_tail,
    Minnow_fin,

    Tutorial,
    Fishemans,

    Interact,
}

@(rodata)
ANIMATION_Entity_main_to_tail := #partial [ANIMATION_Entity_Type]ANIMATION_Entity_Type {
    .Koi = .Koi_tail,
    .Minnow = .Minnow_tail,
}

@(rodata)
ANIMATION_Entity_main_to_fin := #partial [ANIMATION_Entity_Type]ANIMATION_Entity_Type {
    .Koi = .Koi_fin,
    .Minnow = .Minnow_fin,
}

// read only data
// each enum maps 1 to 1 with the name of a sprite sheet
@(rodata)
TEXTURE_Sheet_Names := [ANIMATION_Entity_Type]string {
    .Koi = "koi",
    .Koi_tail = "koi_tail",
    .Koi_fin = "koi_fin",

    .Minnow = "minnow",
    .Minnow_tail = "minnow_tail",
    .Minnow_fin = "minnow_fin",

    .Tutorial = "tutorial",
    .Fishemans = "fishemans",

    .Interact = "interact",
}

// animations are stored in a map with a string as the key.
// to ensure consistent naming patterns, as well as to avoid confusion over what animations actually exist,
// plus avoiding typos,
// all animation strings are stored in constants
// BASIC ANIMATIONS (used by most entities)

ANIMATION_Tag :: enum {
    ANIMATION_IDLE_TAG
}

// The collection type stores the raw texture data
// a union { Texture } is used because its default vaulue is nil, and must be manually checked that it is a texture
// this union will only change from nil to a texture on the load function
// therefore, the program will crash if we try and access unloaded texture data
TEXTURE_Sheet_Collection :: [ANIMATION_Entity_Type] union { rl.Texture2D }

// the pre and post fix for loading sheets
TEXTURE_SHEET_BASE_PATH :: "assets/img/sheets/"
TEXTURE_SHEET_BASE_EXT :: ".png"