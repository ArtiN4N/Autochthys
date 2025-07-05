package src

LEVEL_WIDTH :: 16
LEVEL_HEIGHT :: 16
LEVEL_TILE_SIZE :: 32

LEVEL_COLLISION_CORRECT_MIN_SUBDIV :: 0.2

LEVEL_Tag :: enum {
    Debug = 0,
}

@(rodata)
LEVEL_tag_files: [LEVEL_Tag]string = {
    .Debug = "dev/debug.level"
}

LEVEL_DEFAULT :: LEVEL_Tag.Debug