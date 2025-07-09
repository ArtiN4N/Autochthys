package src

LEVEL_WIDTH :: 16
LEVEL_HEIGHT :: 16
LEVEL_TILE_SIZE :: 48

LEVEL_COLLISION_CORRECT_MIN_SUBDIV :: 0.2

LEVEL_NUM_WORLDS :: 2
LEVEL_WORLDS :: 4

LEVEL_Tag :: enum {
    Open = 0,
    Shell,
}

@(rodata)
LEVEL_tag_files: [LEVEL_Tag]string = {
    .Open = "open.level",
    .Shell = "shell.level",
}

LEVEL_DEFAULT :: LEVEL_Tag.Open

LEVEL_COLLISION_MAX_ITERS :: 100

LEVEL_PLAYER_BEGIN_SPAWN_POS :: FVector{7.5,7.5}