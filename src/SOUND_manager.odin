package src

import rl "vendor:raylib"
import strings "core:strings"

SOUND_FX_Manager :: struct {
    master_list: [SOUND_Tag][SOUND_FX_ALIAS_COUNT]rl.Sound,
    sound_alias_counter_list: [SOUND_Tag]int,
}

SOUND_load_fx_manager_A :: proc(man: ^SOUND_FX_Manager) {
    for tag in SOUND_Tag {
        str_fpath := UTIL_create_filepath_A("assets/sound/", SOUND_tag_files[tag])
        filepath := strings.clone_to_cstring(str_fpath)

        man.master_list[tag][0] = rl.LoadSound(filepath)
        for i in 1..<SOUND_FX_ALIAS_COUNT {
            man.master_list[tag][i] = rl.LoadSoundAlias(man.master_list[tag][0])
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
