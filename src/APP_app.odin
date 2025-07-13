package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"

SAVE_Manager :: struct {
    new: bool,
}

SAVE_create_manager :: proc(man: ^SAVE_Manager) {
    man.new = true
}

App :: struct {
    close: bool,
    cursor_locked: bool,

    state: APP_State,
    game: Game,
    menu: Menu,

    static_trans_data: APP_Static_Transition_Data,

    render_manager: APP_Render_Manager,
    font_manager: FONT_Manager,
    sfx_manager: SOUND_FX_Manager,
    music_manager: SOUND_Music_Manager,
    notification_manager: NOTIFICATION_Manager,
    master_volume: f32,

    texture_collection: TEXTURE_Sheet_Collection,

    save_manager: SAVE_Manager,
}

APP_set_volume :: proc(app: ^App, vol: f32) {
    app.master_volume += vol
    if app.master_volume > 1 do app.master_volume = 1
    if app.master_volume < 0 do app.master_volume = 0
    rl.SetMasterVolume(app.master_volume)
}

APP_load_app_A :: proc(app: ^App) {
    APP_set_volume(app, APP_DEFAULT_M_VOLUME)

    NOTIFICATION_manager_create_A(&app.notification_manager)
    FONT_load_manager_A(&app.font_manager)
    SOUND_load_fx_manager_A(&app.sfx_manager)
    SOUND_load_music_manager_A(&app.music_manager)
    SAVE_create_manager(&app.save_manager)
    APP_load_render_manager_A(&app.render_manager)
    TEXTURE_load_sheet_collections_A(&app.texture_collection)

    APP_app_init_flag = true

    GAME_load_game_A(&app.game)

    TRANSITION_set(.Entry, .Entry)

    log.infof("Application data loaded")
}

APP_destroy_app_D :: proc(app: ^App) {
    if _, ok := app.state.(APP_Dialouge_State); ok {
        DIALOUGE_global_destroy_dialouge_state_D(app)
    }
    if _, ok := app.state.(APP_Savepoint_State); ok {
        SAVEPOINT_global_destroy_savepoint_state_D(app)
    }
    if _, ok := app.state.(APP_Intro_State); ok {
        INTRO_global_destroy_intro_state_D(app)
    }

    TEXTURE_destroy_sheet_collections_D(&app.texture_collection)

    MENU_destroy_menu_D(&app.menu)

    GAME_destroy_game_D(&app.game)

    FONT_destroy_manager_D(&app.font_manager)
    SOUND_destroy_fx_manager_D(&app.sfx_manager)
    SOUND_destroy_music_manager_D(&app.music_manager)
    NOTIFICATION_manager_destroy_D(&app.notification_manager)
    
    APP_destroy_render_manager_D(&app.render_manager)

    log.infof("Application data destroyed")
}