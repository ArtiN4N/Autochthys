package src

LEVEL_WIDTH :: 16
LEVEL_HEIGHT :: 16
LEVEL_TILE_SIZE :: 48

LEVEL_COLLISION_CORRECT_MIN_SUBDIV :: 0.2

LEVEL_NUM_WORLDS :: 2

LEVEL_Tag :: enum {
    Open = 0,
    Shell,
    Almost,
    Crosshair,
    Dice3,
    Dice5,
    Dice6,
    Eye,
    Ghost,
    Han,
    Hideyhole,
    Highway,
    Intersections,
    JJ,
    Randommaze,
    Sidei,
    Snakey,
    Stacks,
    Suprise,
    Yay,
}

@(rodata)
LEVEL_tag_files: [LEVEL_Tag]string = {
    .Open = "open.level",
    .Shell = "shell.level",
    .Almost = "almost.level",
    .Crosshair = "crosshair.level",
    .Dice3 = "dice3.level",
    .Dice5 = "dice5.level",
    .Dice6 = "dice6.level",
    .Eye = "eye.level",
    .Ghost = "ghost.level",
    .Han = "han.level",
    .Hideyhole = "hideyhole.level",
    .Highway = "highway.level",
    .Intersections = "intersections.level",
    .JJ = "jj.level",
    .Randommaze = "randommaze.level",
    .Sidei = "sidei.level",
    .Snakey = "snakey.level",
    .Stacks = "stacks.level",
    .Suprise = "suprise.level",
    .Yay = "yay.level",
}

LEVEL_DEFAULT :: LEVEL_Tag.Open
LEVEL_COLLISION_MAX_ITERS :: 100
LEVEL_PLAYER_BEGIN_SPAWN_POS :: FVector{7.5,7.5}