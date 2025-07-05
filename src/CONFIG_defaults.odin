package src

import rl "vendor:raylib"
import log "core:log"

// to be replaced by something that loads saved configs
CONFIG_set_default_configs :: proc(man: ^CONFIG_Manager) {
    log.infof("Loading user configs")

    man.curr_values.vsync             = false
    man.curr_values.fullscreen        = false
    man.curr_values.resizable         = false
    man.curr_values.undecorated       = false
    man.curr_values.hidden            = false
    man.curr_values.minimized         = false
    man.curr_values.maximized         = false
    man.curr_values.run_minimized     = false
    man.curr_values.borderless_window = false

    man.curr_values.fps = CONFIG_DEFAULT_WINDOW_FPS

    man.curr_values.screen_width = CONFIG_DEFAULT_SCREEN_WIDTH
    man.curr_values.screen_height = CONFIG_DEFAULT_SCREEN_HEIGHT
}

CONFIG_init_configs :: proc(man: ^CONFIG_Manager) {
    CONFIG_set_default_configs(man)
    CONFIG_apply_configs(man)
    
    log.infof("Initial configs set")
}