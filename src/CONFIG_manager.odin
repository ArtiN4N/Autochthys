package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"

CONFIG_Values :: struct {
    // window flags
    vsync,
    fullscreen,
    resizable,
    undecorated,
    hidden,
    minimized,
    maximized,
    run_minimized,
    borderless_window: bool,

    fps: i32,

    screen_width, screen_height: i32,
}

CONFIG_Manager :: struct {
    curr_values: CONFIG_Values,
    prev_values: CONFIG_Values,
}

// saves user configs to be loaded on boot next time
CONFIG_save_configs :: proc() {
    log.infof("Saving user configs")
}

// checks which configs have changed and updates them
CONFIG_apply_configs :: proc(man: ^CONFIG_Manager) {
    curr := man.curr_values
    prev := man.prev_values

    clear_flags: rl.ConfigFlags
    set_flags: rl.ConfigFlags

    if curr.vsync != prev.vsync  {
        if curr.vsync { set_flags   += {.VSYNC_HINT} }
        else          { clear_flags += {.VSYNC_HINT} }
    }

    if curr.fullscreen != prev.fullscreen  {
        if curr.fullscreen { set_flags   += {.FULLSCREEN_MODE} }
        else               { clear_flags += {.FULLSCREEN_MODE} }
    }

    if curr.resizable != prev.resizable  {
        if curr.resizable { set_flags   += {.WINDOW_RESIZABLE} }
        else              { clear_flags += {.WINDOW_RESIZABLE} }
    }

    if curr.undecorated != prev.undecorated  {
        if curr.undecorated { set_flags   += {.WINDOW_UNDECORATED} }
        else                { clear_flags += {.WINDOW_UNDECORATED} }
    }

    if curr.hidden != prev.hidden  {
        if curr.hidden { set_flags   += {.WINDOW_HIDDEN} }
        else           { clear_flags += {.WINDOW_HIDDEN} }
    }

    if curr.minimized != prev.minimized  {
        if curr.minimized { set_flags   += {.WINDOW_MINIMIZED} }
        else              { clear_flags += {.WINDOW_MINIMIZED} }
    }

    if curr.maximized != prev.maximized  {
        if curr.maximized { set_flags   += {.WINDOW_MAXIMIZED} }
        else              { clear_flags += {.WINDOW_MAXIMIZED} }
    }

    if curr.run_minimized != prev.run_minimized  {
        if curr.run_minimized { set_flags   += {.WINDOW_ALWAYS_RUN} }
        else                  { clear_flags += {.WINDOW_ALWAYS_RUN} }
    }

    if curr.borderless_window != prev.borderless_window  {
        if curr.borderless_window { set_flags   += {.BORDERLESS_WINDOWED_MODE} }
        else                      { clear_flags += {.BORDERLESS_WINDOWED_MODE} }
    }

    rl.ClearWindowState(clear_flags)
    rl.SetWindowState(set_flags)

    log.infof("Config flags cleared: %v", clear_flags)
    log.infof("Config flags set: %v", set_flags)

    rl.SetTargetFPS(curr.fps)

    log.infof("FPS set to: %v", curr.fps)

    rl.SetWindowSize(curr.screen_width, curr.screen_height)
    log.infof("screen size set to: %v,%v", curr.screen_width, curr.screen_height)

    // updates previous values
    man.prev_values = man.curr_values
}

CONFIG_get_global_screen_size :: proc() -> (width, height: i32) {
    return APP_global_config_man.curr_values.screen_width, APP_global_config_man.curr_values.screen_height
}