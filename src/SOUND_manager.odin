package src

import rl "vendor:raylib"
import rand "core:math/rand"
import strings "core:strings"

SOUND_FX_Manager :: struct {
    master_list: [SOUND_Tag][SOUND_FX_ALIAS_COUNT]rl.Sound,
    sound_alias_counter_list: [SOUND_Tag]int,
    volume: f32,
}

SOUND_set_fx_volume :: proc(man: ^SOUND_FX_Manager, vol: f32) {
    man.volume += vol
    if man.volume > 1 do man.volume = 1
    if man.volume < 0 do man.volume = 0
    
    for tag in SOUND_Tag {
        rl.SetSoundVolume(man.master_list[tag][0], man.volume)
        for i in 1..<SOUND_FX_ALIAS_COUNT {
            rl.SetSoundVolume(man.master_list[tag][i], man.volume)
        }
    }
}

SOUND_load_fx_manager_A :: proc(man: ^SOUND_FX_Manager) {
    man.volume = SOUND_FX_DEFAULT_VOL
    for tag in SOUND_Tag {
        str_fpath := UTIL_create_filepath_A(SOUND_FX_PATH_PREFIX, SOUND_tag_files[tag])
        filepath := strings.clone_to_cstring(str_fpath)

        man.master_list[tag][0] = rl.LoadSound(filepath)
        rl.SetSoundVolume(man.master_list[tag][0], man.volume)
        for i in 1..<SOUND_FX_ALIAS_COUNT {
            man.master_list[tag][i] = rl.LoadSoundAlias(man.master_list[tag][0])
            rl.SetSoundVolume(man.master_list[tag][i], man.volume)
        }

        delete(filepath)
        delete(str_fpath)
    }

    man.sound_alias_counter_list = {}
}

SOUND_destroy_fx_manager_D :: proc(man: ^SOUND_FX_Manager) {
    for tag in SOUND_Tag {
        for i in 1..<SOUND_FX_ALIAS_COUNT {
            rl.UnloadSoundAlias(man.master_list[tag][i])
        }
        rl.UnloadSound(man.master_list[tag][0])
    }
}

SOUND_global_fx_manager_play_tag :: proc(tag: SOUND_Tag) {
    man := &APP_global_app.sfx_manager
    cur_alias := man.sound_alias_counter_list[tag]
    rl.PlaySound(man.master_list[tag][cur_alias])

    man.sound_alias_counter_list[tag] += 1
    if man.sound_alias_counter_list[tag] >= SOUND_FX_ALIAS_COUNT {
        man.sound_alias_counter_list[tag] = 0
    }
}

SOUND_global_fx_choose_parry_sound :: proc() {
    man := &APP_global_app.sfx_manager

    choice := rand.choice(SOUND_parry_choices[:])

    SOUND_global_fx_manager_play_tag(choice)
}
