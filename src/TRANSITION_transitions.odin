package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"

TRANSITION_main_menu_to_game :: proc() {
    log.infof("State transition from menu to game")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Menu, .Game, 2)

    rw, rh := APP_get_global_render_size()
    rl.SetMousePosition(rw / 2, rh / 2)
    rl.DisableCursor()
    log.infof("Disabled cursor")
}

TRANSITION_to_from_level :: proc(from: LEVEL_Tag, dir: FVector) {
    app := &APP_global_app

    app.state = APP_create_transition_state(.Game, .Game, 0.5, from, dir)
    log.infof("State transition from level to level")
}

TRANSITION_game_to_inventory :: proc() {
    log.infof("State transition from game to inventory")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Game, .Inventory, 0.5)
}

TRANSITION_inventory_to_game :: proc() {
    log.infof("State transition from inventory to game")

    app := &APP_global_app
    app.state = APP_create_transition_state(.Inventory, .Game, 0.5)
}