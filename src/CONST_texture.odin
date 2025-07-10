package src

import rl "vendor:raylib"

ANIMATION_Entity_Type :: enum {
    Player,
    //Minnow,
    //Koi,
    //Octopus,
}

// read only data
// each enum maps 1 to 1 with the name of a sprite sheet
@(rodata)
TEXTURE_Sheet_Names := [ANIMATION_Entity_Type]string {
    .Player = "player",
    //.Minnow = "",
    //.Koi = "",
    //.Octopus = "",
}

// animations are stored in a map with a string as the key.
// to ensure consistent naming patterns, as well as to avoid confusion over what animations actually exist,
// plus avoiding typos,
// all animation strings are stored in constants
// BASIC ANIMATIONS (used by most entities)
ANIMATION_IDLE_TAG :: "idle"
ANIMATION_RUN_TAG :: "run"
ANIMATION_ATTACK_TAG :: "attack"
ANIMATION_DIE_TAG :: "die"

// The collection type stores the raw texture data
// a union { Texture } is used because its default vaulue is nil, and must be manually checked that it is a texture
// this union will only change from nil to a texture on the load function
// therefore, the program will crash if we try and access unloaded texture data
TEXTURE_Sheet_Collection :: [ANIMATION_Entity_Type] union { rl.Texture2D }

// the pre and post fix for loading sheets
TEXTURE_SHEET_BASE_PATH :: "assets/img/sheets/"
TEXTURE_SHEET_BASE_EXT :: ".png"