package src

import log "core:log"
import fmt "core:fmt"

APP_global_reset_on_death :: proc() {
    app := &APP_global_app

    SOUND_global_music_remove_all()
    GAME_destroy_game_D(&app.game)
    GAME_load_game_A(&app.game)

    log.infof("Application data reset")
}