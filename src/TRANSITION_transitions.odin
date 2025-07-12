package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"

TRANSITION_set :: proc(from, to: APP_Functional_State) {
    app := &APP_global_app
    trans_data := &app.static_trans_data
    level_man := &app.game.level_manager

    #partial switch from {
    case .Game:

        #partial switch to {
        case .Game:
            TRANSITION_from_level_to_level(app.game.level_manager.travel_dir)
            TRANSITION_global_draw_game(trans_data.to_tex, level_man.current_level, true, true)
            return
        case .Inventory:
            TRANSITION_global_draw_game(trans_data.from_tex, level_man.current_level, true, true)
            TRANSITION_from_game_to_inventory()
            TRANSITION_global_draw_inventory(trans_data.to_tex)
            return
        case .Dialouge:
            TRANSITION_from_game_to_dialouge()
            return
        case .Savepoint:
            TRANSITION_from_game_to_savepoint()
            return
        }

    case .Inventory:
        TRANSITION_global_draw_inventory(trans_data.to_tex)

        #partial switch to {
        case .Game:
            TRANSITION_from_inventory_to_game()
            TRANSITION_global_draw_game(trans_data.from_tex, level_man.current_level)
            return
        }

    case .Menu:
        TRANSITION_global_draw_menu(trans_data.from_tex)
        
        #partial switch to {
        case .Game:
            TRANSITION_from_main_menu_to_game()
            TRANSITION_global_draw_game(trans_data.to_tex, level_man.current_level)
            return
        }
    
    case .Dialouge:
        #partial switch to {
        case .Game:
            TRANSITION_from_dialouge_to_game()
            return
        }
    case .Savepoint:
        #partial switch to {
        case .Game:
            TRANSITION_from_savepoint_to_game()
            return
        }
    }
    log.fatalf("Invalid transition attempt from %v to %v", from, to)
    panic("check log")
}

TRANSITION_from_game_to_savepoint :: proc() {
    log.infof("State transition from game to savepoint")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Game, .Savepoint, 0)

    SOUND_global_music_remove_all()
    SOUND_global_music_manager_add_tag(SOUND_music_savepoint_tag)
}

TRANSITION_from_savepoint_to_game :: proc() {
    log.infof("State transition from savepoint to game")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Savepoint, .Game, 0)

    SOUND_global_music_manager_remove_tag(SOUND_music_savepoint_tag)
    man := &app.game.level_manager
    SOUND_global_music_play_by_room(man.current_room)
}

TRANSITION_from_dialouge_to_game :: proc() {
    log.infof("State transition from dialouge to game")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Dialouge, .Game, 0)

    SOUND_global_music_manager_remove_tag(SOUND_music_npc_tag)

    man := &app.game.level_manager
    SOUND_global_music_play_by_room(man.current_room)
}

TRANSITION_from_game_to_dialouge :: proc() {
    log.infof("State transition from game to dialouge")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Game, .Dialouge, 0)

    SOUND_global_music_manager_add_tag(SOUND_music_npc_tag)
}

TRANSITION_from_main_menu_to_game :: proc() {
    log.infof("State transition from menu to game")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Menu, .Game, 2)

    rw, rh := APP_get_global_render_size()
    rl.SetMousePosition(i32(rw / 2), i32(rh / 2))
    rl.DisableCursor()

    SOUND_global_music_manager_remove_tag(SOUND_music_menu_tag)
    LEVEL_global_manager_enter_world()

    log.infof("Disabled cursor")
}

TRANSITION_from_level_to_level :: proc(dir: LEVEL_Room_Connection) {
    app := &APP_global_app
    app.static_trans_data.warp_dir = dir

    app.state = APP_create_transition_state(.Game, .Game, 0.5)
    log.infof("State transition from level to level")
}

TRANSITION_from_game_to_inventory :: proc() {
    log.infof("State transition from game to inventory")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Game, .Inventory, 0.5)
}

TRANSITION_from_inventory_to_game :: proc() {
    log.infof("State transition from inventory to game")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Inventory, .Game, 0.5)
}