package src

SOUND_FX_ALIAS_COUNT :: 5

SOUND_FX_DEFAULT_VOL :: 0.5



SOUND_Tag :: enum {
    Ship_Shoot = 0,
    Player_Xp_Pickup,
    Player_Levelup,

    Parry1,
    Parry2,
    Parry3,
    Parry4,
    Parry5,
    Parry6,
    Parry7,
    Parry8,
    Parry9,

    Die1,
    Die2,
    Die3,
    Die4,
    Die5,
    Die6,
    Die7,
    Die8,

    Player_Hit1,
    Player_Hit2,
    Player_Hit3,
    Player_Hit4,
    Player_Hit5,
    Player_Hit6,
    Player_Hit7,
    Player_Hit8,

    Enemy_Hit1,
    Enemy_Hit2,
    Enemy_Hit3,
    Enemy_Hit4,
    Enemy_Hit5,

    Notification1,
    Notification2,
    Notification3,

    Menu_hover,
    Menu_click,

    Tutorial_Voice,
    Man_Voice,

    Reload,
    Good_Parry_Swing,
    Bad_Parry_Swing,
}

@(rodata)
SOUND_die_choices := [8]SOUND_Tag {
    .Die1,
    .Die2,
    .Die3,
    .Die4,
    .Die5,
    .Die6,
    .Die7,
    .Die8,
}

@(rodata)
SOUND_player_hit_choices := [8]SOUND_Tag {
    .Player_Hit1,
    .Player_Hit2,
    .Player_Hit3,
    .Player_Hit4,
    .Player_Hit5,
    .Player_Hit6,
    .Player_Hit7,
    .Player_Hit8,
}

@(rodata)
SOUND_enemy_hit_choices := [5]SOUND_Tag {
    .Enemy_Hit1,
    .Enemy_Hit2,
    .Enemy_Hit3,
    .Enemy_Hit4,
    .Enemy_Hit5,
}

@(rodata)
SOUND_noti_choices := [3]SOUND_Tag {
    .Notification1,
    .Notification2,
    .Notification3,
}

@(rodata)
SOUND_parry_choices := [9]SOUND_Tag {
    .Parry1,
    .Parry2,
    .Parry3,
    .Parry4,
    .Parry5,
    .Parry6,
    .Parry7,
    .Parry8,
    .Parry9,
}

SOUND_FX_PATH_PREFIX :: "assets/sound/"

@(rodata)
SOUND_tag_files: [SOUND_Tag]string = {
    .Ship_Shoot = "ship/bubble.wav",
    .Player_Xp_Pickup = "ship/exp_pickup.wav",
    .Player_Levelup = "ship/levelup.wav",
    .Reload = "ship/reload.wav",

    .Parry1 = "metal/metal_1.wav",
    .Parry2 = "metal/metal_2.wav",
    .Parry3 = "metal/metal_3.wav",
    .Parry4 = "metal/metal_4.wav",
    .Parry5 = "metal/metal_5.wav",
    .Parry6 = "metal/metal_6.wav",
    .Parry7 = "metal/metal_7.wav",
    .Parry8 = "metal/metal_8.wav",
    .Parry9 = "metal/metal_9.wav",

    .Menu_hover = "menu/select.wav",
    .Menu_click = "menu/click.wav",

    .Tutorial_Voice = "npc/tutorial.wav",
    .Man_Voice = "npc/man.wav",

    .Notification1 = "bell/bell_1.wav",
    .Notification2 = "bell/bell_2.wav",
    .Notification3 = "bell/bell_3.wav",

    .Enemy_Hit1 = "hit/hit_1.wav",
    .Enemy_Hit2 = "hit/hit_2.wav",
    .Enemy_Hit3 = "hit/hit_3.wav",
    .Enemy_Hit4 = "hit/hit_4.wav",
    .Enemy_Hit5 = "hit/hit_5.wav",

    .Player_Hit1 = "player_hit/impact_1.wav",
    .Player_Hit2 = "player_hit/impact_2.wav",
    .Player_Hit3 = "player_hit/impact_3.wav",
    .Player_Hit4 = "player_hit/impact_4.wav",
    .Player_Hit5 = "player_hit/impact_5.wav",
    .Player_Hit6 = "player_hit/impact_6.wav",
    .Player_Hit7 = "player_hit/impact_7.wav",
    .Player_Hit8 = "player_hit/impact_8.wav",

    .Die1 = "impact/impact_1.wav",
    .Die2 = "impact/impact_2.wav",
    .Die3 = "impact/impact_3.wav",
    .Die4 = "impact/impact_4.wav",
    .Die5 = "impact/impact_5.wav",
    .Die6 = "impact/impact_6.wav",
    .Die7 = "impact/impact_7.wav",
    .Die8 = "impact/impact_8.wav",

    .Good_Parry_Swing = "metal/parryswing.wav",
    .Bad_Parry_Swing = "metal/badswing.wav",
}

SOUND_MUSIC_FADE_SPEED :: 1

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
    Malfunction,
    Water,
}

SOUND_music_menu_tag :: MUSIC_Tag.Sin_chill
SOUND_music_passive_tag :: MUSIC_Tag.Pensive_chill
SOUND_music_npc_tag :: MUSIC_Tag.Bright_chill
SOUND_music_savepoint_tag :: MUSIC_Tag.Sin_chill
SOUND_music_low_hp_tag :: MUSIC_Tag.Malfunction

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


SOUND_MUSIC_PATH_PREFIX :: "assets/music/"

@(rodata)
SOUND_music_tag_files: [MUSIC_Tag]string = {
    .Sin_chill = "gen1/track01_sinchill.mp3",
    .Pensive_chill = "gen1/track02_pensivechill.mp3",
    .Bright_chill = "gen1/track03_brightchill.mp3",
    .Lost_chill = "gen1/track04_lostchill.mp3",
    .Wonder_chill = "gen1/track05_wonderchill.mp3",
    .Uplift_chill = "gen1/track06_upliftchill.mp3",
    .Light_battle = "gen1/track07_lightbattle.mp3",
    .Tense_battle = "gen1/track08_tensebattle.mp3",
    .Difficult_battle = "gen1/track09_difficultbattle.mp3",
    .Hell = "gen1/track10_hell.mp3",
    .Malfunction = "gen1/track11_malfunction.mp3",
    .Water = "ambience/water.mp3",
}