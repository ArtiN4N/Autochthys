package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import strings "core:strings"

SOUND_Music_Manager :: struct {
    master_list: [MUSIC_Tag]rl.Music,
    active_tracks: [MUSIC_Tag]bool,
    track_volumes: [MUSIC_Tag]f32,
    volume: f32,
}

SOUND_set_music_volume :: proc(man: ^SOUND_Music_Manager, vol: f32) {
    man.volume += vol
    if man.volume > 1 do man.volume = 1
    if man.volume < 0 do man.volume = 0
    for tag in MUSIC_Tag {
        if !man.active_tracks[tag] do continue
        man.track_volumes[tag] = vol
        rl.SetMusicVolume(man.master_list[tag], vol)
    }
}

SOUND_load_music_manager_A :: proc(man: ^SOUND_Music_Manager) {
    man.volume = 1

    rl.SetMasterVolume(1)
    for tag in MUSIC_Tag {
        str_fpath := UTIL_create_filepath_A(SOUND_MUSIC_PATH_PREFIX, SOUND_music_tag_files[tag])
        filepath := strings.clone_to_cstring(str_fpath)

        man.master_list[tag] = rl.LoadMusicStream(filepath)

        delete(filepath)
        delete(str_fpath)

        man.active_tracks[tag] = false
    }

    for tag in MUSIC_Tag {
        rl.PlayMusicStream(man.master_list[tag])
        rl.SetMusicVolume(man.master_list[tag], 0)
        man.track_volumes[tag] = 0
    }

    SOUND_global_music_manager_add_tag(SOUND_music_menu_tag)
}

SOUND_destroy_music_manager_D :: proc(man: ^SOUND_Music_Manager) {
    for tag in MUSIC_Tag {
        rl.StopMusicStream(man.master_list[tag])
    }

    for tag in MUSIC_Tag {
        rl.UnloadMusicStream(man.master_list[tag])
    }
}

SOUND_global_modify_low_hp_track :: proc() {
    man := &APP_global_app.music_manager
    hp := APP_global_app.game.player.hp

    max_vol := man.volume
    hp_ratio := (hp / STATS_global_player_max_hp()) * 2
    hp_ratio = 1 - min(1, hp_ratio)

    ratioed_vol := max_vol * hp_ratio
    ratioed_vol = min(1, ratioed_vol)

    old_vol := man.track_volumes[.Malfunction]
    man.track_volumes[.Malfunction] = ratioed_vol
    
    
    if old_vol != man.track_volumes[.Malfunction] {
        rl.SetMusicVolume(man.master_list[.Malfunction], ratioed_vol)
    }
}

SOUND_global_modify_water_track :: proc() {
    man := &APP_global_app.music_manager
    
    if _, ok := APP_global_app.state.(APP_Game_State); !ok {
        if _, ok := APP_global_app.state.(APP_Menu_State); ok {
            rl.SetMusicVolume(man.master_list[.Water], 0)
        }
        return
    }
    
    
    mag := vector_magnitude(APP_global_app.game.player.move_dir) * STATS_global_player_speed()

    if mag == 0 {
        rl.SetMusicVolume(man.master_list[.Water], 0.1)
    } else {
        rl.SetMusicVolume(man.master_list[.Water], 0.3)
    }
}

SOUND_global_music_manager_update :: proc() {
    man := &APP_global_app.music_manager
    for tag in MUSIC_Tag {
        defer rl.UpdateMusicStream(man.master_list[tag])
        if tag == .Malfunction {
            SOUND_global_modify_low_hp_track()
            continue
        }
        if tag == .Water {
            SOUND_global_modify_water_track()
            continue
        }

        if man.active_tracks[tag] && man.track_volumes[tag] < man.volume {
            vol := man.track_volumes[tag] + SOUND_MUSIC_FADE_SPEED * dt
            if vol > man.volume do vol = man.volume

            rl.SetMusicVolume(man.master_list[tag], vol)
            man.track_volumes[tag] = vol
        } else if !man.active_tracks[tag] && man.track_volumes[tag] > 0 {
            vol := man.track_volumes[tag] - SOUND_MUSIC_FADE_SPEED * dt
            if vol < 0 do vol = 0

            rl.SetMusicVolume(man.master_list[tag], vol)
            man.track_volumes[tag] = vol
        }
        

        
    }
}

SOUND_global_music_manager_add_tag :: proc(tag: MUSIC_Tag) {
    man := &APP_global_app.music_manager

    man.active_tracks[tag] = true
}

SOUND_global_music_manager_remove_tag :: proc(tag: MUSIC_Tag) {
    man := &APP_global_app.music_manager

    man.active_tracks[tag] = false
}

SOUND_global_music_add_aggression :: proc(aggr: int) {
    for tie in SOUND_music_combat_tags {
        if aggr >= tie.aggr do SOUND_global_music_manager_add_tag(tie.tag)
    }
}

SOUND_global_room_add_music :: proc(room: LEVEL_Room_World_Index) {
    man := &APP_global_app.game.level_manager
    world := &APP_global_app.game.current_world

    if _, ok := world.rooms[room].type.(LEVEL_Passive_Room); ok {
        SOUND_global_music_manager_add_tag(.Pensive_chill)
    } else if aggr, ok := world.rooms[room].type.(LEVEL_Aggressive_Room); ok {
        if aggr.aggression_level == 0 do SOUND_global_music_manager_add_tag(.Pensive_chill)

        else {
            SOUND_global_music_add_aggression(aggr.aggression_level)
            if world.rooms[room].is_miniboss do SOUND_global_music_manager_add_tag(.Hell)
        }
    }
}

SOUND_global_music_remove_all :: proc() {
    man := &APP_global_app.music_manager
    for tag in MUSIC_Tag {
        SOUND_global_music_manager_remove_tag(tag)
    }
}

SOUND_global_music_play_by_room :: proc(room: LEVEL_Room_World_Index) {
    SOUND_global_music_remove_all()

    SOUND_global_room_add_music(room)
    SOUND_global_music_manager_add_tag(.Lost_chill)
}

SOUND_global_music_log_tags :: proc() {
    man := &APP_global_app.music_manager
    for tag in MUSIC_Tag {
        log.infof("Music tag %v set to %v", tag, man.active_tracks[tag])
    }
}