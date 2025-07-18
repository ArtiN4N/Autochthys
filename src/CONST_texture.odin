package src

import rl "vendor:raylib"

ANIMATION_Entity_Type :: enum {
    Koi,
    Koi_tail,
    Koi_fin,

    Minnow,
    Minnow_tail,
    Minnow_fin,

    Needlefish,
    Needlefish_tail,
    Needlefish_fin,

    Tutorial,

    Interact,
    Savepoint,

    Tile_Air,
    Tile_Wall,

    ITEM_Key,
    ITEM_Giver,
    ITEM_Charm,
    ITEM_SusKey,
    ITEM_Housekey,
    ITEM_Wallet,
    ITEM_Clip,

    Badass_npc,
    Charm_npc,
    Clip_npc,
    Dog_npc,
    Drummer_npc,
    Dudebro_npc,
    House_npc,
    Imposer_npc,
    Wallet_npc,

    Eel_Head,
    Eel_Tail,
    Eel_Upper,
    Eel_Lower,
}

@(rodata)
ANIMATION_Entity_main_to_tail := #partial [ANIMATION_Entity_Type]ANIMATION_Entity_Type {
    .Koi = .Koi_tail,
    .Minnow = .Minnow_tail,
    .Needlefish = .Needlefish_tail,
}

@(rodata)
ANIMATION_Entity_main_to_fin := #partial [ANIMATION_Entity_Type]ANIMATION_Entity_Type {
    .Koi = .Koi_fin,
    .Minnow = .Minnow_fin,
    .Needlefish = .Needlefish_fin,
}

// read only data
// each enum maps 1 to 1 with the name of a sprite sheet
@(rodata)
TEXTURE_Sheet_Names := [ANIMATION_Entity_Type]string {
    .Koi = "sheets/koi",
    .Koi_tail = "sheets/koi_tail",
    .Koi_fin = "sheets/koi_fin",

    .Minnow = "sheets/minnow",
    .Minnow_tail = "sheets/minnow_tail",
    .Minnow_fin = "sheets/minnow_fin",

    .Needlefish = "sheets/needlefish",
    .Needlefish_tail = "sheets/needlefish_tail",
    .Needlefish_fin = "sheets/needlefish_fin",

    .Tutorial = "npc/tutorial",

    .Interact = "npc/interact",
    .Savepoint = "npc/hook",

    .Tile_Air = "tile/air",
    .Tile_Wall = "tile/wall_tiles2",

    .ITEM_Key = "item/key",
    .ITEM_Giver = "npc/fishemans",
    .ITEM_Charm = "item/charm",
    .ITEM_SusKey = "item/suskey",
    .ITEM_Housekey = "item/housekey",
    .ITEM_Wallet = "item/wallet",
    .ITEM_Clip = "item/clip",

    .Badass_npc = "npc/Badass",
    .Charm_npc = "npc/CharmGiver",
    .Clip_npc = "npc/ClipGiver",
    .Dog_npc = "npc/dog",
    .Drummer_npc = "npc/Drummer",
    .Dudebro_npc = "npc/HelpfulDude",
    .House_npc = "npc/HouseKeyGiver",
    .Imposer_npc = "npc/imposer",
    .Wallet_npc = "npc/WalletGiver",

    .Eel_Head = "sheets/eel_head",
    .Eel_Tail = "sheets/eel_tail",
    .Eel_Upper = "sheets/eel_upper_body",
    .Eel_Lower = "sheets/eel_lower_body",
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
TEXTURE_SHEET_BASE_PATH :: "assets/img/"
TEXTURE_SHEET_BASE_EXT :: ".png"