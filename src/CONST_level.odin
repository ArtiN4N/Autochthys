package src

LEVEL_WIDTH :: 16
LEVEL_HEIGHT :: 16
LEVEL_TILE_SIZE :: 48

LEVEL_COLLISION_CORRECT_MIN_SUBDIV :: 0.2

LEVEL_NUM_WORLDS :: 2

LEVEL_Tag :: enum {
    Debug_L00 = 0,
    Debug_L01,
    W1_L00,
    W1_L01,
    W1_L02,
    W1_L03,
    W1_L04,
    W1_L05,
    W1_L06,
    W1_L07,
    W1_L08,
    W1_L09,
    W1_L10,
}

// because level numbers reset back to 1 on new worlds, we need a read-only array of
// enum offsets
// basically, warps are stored in level files via a single integer
// which corresponds to the level in that world with that number
// so, if a world 1 level 2 wants to warp to level 9,
// then we need to access level 9's tag with just that number
// this causes problems when world x's level 0 is not the first enum
// which must be true for at all worlds except wortld 1
// however, as long as enum orderings stay contiguous and ordered,
// we can just add a pre-computed offset to the level tag
// based on the world number
// and this will find our correct level
@(rodata)
LEVEL_tag_offsets_by_world: [LEVEL_NUM_WORLDS]int = {
    0,
    2,
}

@(rodata)
LEVEL_tag_files: [LEVEL_Tag]string = {
    .Debug_L00 = "dev/debug.level",
    .Debug_L01 = "dev/test.level",

    .W1_L00 = "world1/00.level",
    .W1_L01 = "world1/01.level",
    .W1_L02 = "world1/02.level",
    .W1_L03 = "world1/03.level",
    .W1_L04 = "world1/04.level",
    .W1_L05 = "world1/05.level",
    .W1_L06 = "world1/06.level",
    .W1_L07 = "world1/07.level",
    .W1_L08 = "world1/08.level",
    .W1_L09 = "world1/09.level",
    .W1_L10 = "world1/10.level",
}

LEVEL_DEFAULT :: LEVEL_Tag.W1_L00

LEVEL_COLLISION_MAX_ITERS :: 100