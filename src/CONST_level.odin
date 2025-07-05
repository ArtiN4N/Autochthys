package src

LEVEL_WIDTH :: 32
LEVEL_HEIGHT :: 32
LEVEL_TILE_SIZE :: 16

LEVEL_Tag :: enum {
    Debug = 0,
}

@(rodata)
LEVEL_tag_files: [LEVEL_Tag]string = {
    .Debug = "dev/debug.level"
}

LEVEL_DEFAULT :: LEVEL_Tag.Debug