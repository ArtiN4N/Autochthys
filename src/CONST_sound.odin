package src

SOUND_Tag :: enum {
    Ship_Shoot = 0,
    Ship_Hurt,
    Ship_Die,
    Player_Xp_Pickup,
    Player_Levelup,
    Player_Parry,
}

@(rodata)
SOUND_tag_files: [SOUND_Tag]string = {
    .Ship_Shoot = "ship/shoot.wav",
    .Ship_Hurt = "ship/hurt.wav",
    .Ship_Die = "explosion.wav",
    .Player_Xp_Pickup = "ship/exp_pickup.wav",
    .Player_Levelup = "ship/levelup.wav",
    .Player_Parry = "ship/parry.wav"
}

SOUND_FX_ALIAS_COUNT :: 5