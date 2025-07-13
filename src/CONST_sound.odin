package src

SOUND_FX_ALIAS_COUNT :: 5

SOUND_FX_PATH_PREFIX :: "assets/sound/"

SOUND_Tag :: enum {
    Ship_Shoot = 0,
    Ship_Hurt,
    Ship_Die,
    Player_Xp_Pickup,
    Player_Levelup,
    Player_Parry,

    Menu_hover,
    Menu_click,

    Tutorial_Voice,
    Man_Voice,
}

@(rodata)
SOUND_tag_files: [SOUND_Tag]string = {
    .Ship_Shoot = "ship/shoot.wav",
    .Ship_Hurt = "ship/hurt.wav",
    .Ship_Die = "explosion.wav",
    .Player_Xp_Pickup = "ship/exp_pickup.wav",
    .Player_Levelup = "ship/levelup.wav",
    .Player_Parry = "ship/parry.wav",

    .Menu_hover = "menu/select.wav",
    .Menu_click = "menu/click.wav",

    .Tutorial_Voice = "npc/tutorial.wav",
    .Man_Voice = "npc/man.wav",
}

SOUND_MUSIC_FADE_SPEED :: 1

SOUND_MUSIC_PATH_PREFIX :: "assets/music/gen1/track"

MUSIC_Tag :: enum {
    Sin_chill,
    Pensive_chill,
    Bright_chill,
    Lost_chill,
    Wonder_chill,
    Uplift_chill,
    Light_battle,
    Tense_battle,
    Difficult_battle,
    Hell,
}

SOUND_music_menu_tag :: MUSIC_Tag.Sin_chill
SOUND_music_passive_tag :: MUSIC_Tag.Pensive_chill
SOUND_music_npc_tag :: MUSIC_Tag.Bright_chill
SOUND_music_savepoint_tag :: MUSIC_Tag.Sin_chill

SOUND_Music_Combat_Tie :: struct {
    tag: MUSIC_Tag,
    aggr: int,
}

@(rodata)
SOUND_music_combat_tags := []SOUND_Music_Combat_Tie {
    {.Wonder_chill, LEVEL_CONNECTOR_AGGR},
    {.Light_battle, LEVEL_START_BLOCK_AGGR},
    {.Tense_battle, LEVEL_OTHER_BLOCK_AGGR},
    {.Difficult_battle, LEVEL_TAIL_AGGR},
}


@(rodata)
SOUND_music_tag_files: [MUSIC_Tag]string = {
    .Sin_chill = "01_sinchill.mp3",
    .Pensive_chill = "02_pensivechill.mp3",
    .Bright_chill = "03_brightchill.mp3",
    .Lost_chill = "04_lostchill.mp3",
    .Wonder_chill = "05_wonderchill.mp3",
    .Uplift_chill = "06_upliftchill.mp3",
    .Light_battle = "07_lightbattle.mp3",
    .Tense_battle = "08_tensebattle.mp3",
    .Difficult_battle = "09_difficultbattle.mp3",
    .Hell = "10_hell.mp3",
}