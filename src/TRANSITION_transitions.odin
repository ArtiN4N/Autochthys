package src

import rl "vendor:raylib"
import log "core:log"

TRANSITION_main_menu_to_game :: proc() {
    log.infof("State transition from menu to game")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Menu, .Game, 1)

    rw, rh := APP_get_global_render_size()
    rl.SetMousePosition(rw / 2, rh / 2)
    rl.DisableCursor()
    log.infof("Disabled cursor")
}