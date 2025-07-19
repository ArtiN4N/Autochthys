package src

import rl "vendor:raylib"
import os "core:os"
import mem "core:mem"
import fmt "core:fmt"
import log "core:log"
import rand "core:math/rand"

APP_global_app: App
APP_global_config_man: CONFIG_Manager
APP_tracking_alloc: mem.Tracking_Allocator
APP_logger: log.Logger

dt: f32
total_t: f64
rng := rand.default_random_generator()

main :: proc() {
    when ODIN_DEBUG {
        // The tracking allocator tracks double frees and unfreed memory
        APP_tracking_alloc = UTIL_create_tracking_allocator_A()
        context.allocator = mem.tracking_allocator(&APP_tracking_alloc)
    }

    UTIL_init_logger_A()
    context.logger = APP_logger

    
    rl.InitWindow(CONFIG_DEFAULT_SCREEN_WIDTH, CONFIG_DEFAULT_SCREEN_HEIGHT, "Autochthys")
    log.infof("Raylib window opened")

    icon := rl.LoadImage("assets/img/icon.png")
    rl.SetWindowIcon(icon)
    rl.UnloadImage(icon)

    rl.SetExitKey(.KEY_NULL)

    rl.InitAudioDevice()
    APP_raylib_init_flag = true
    log.infof("Raylib audio opened")

    config_man := &APP_global_config_man
    CONFIG_init_configs(config_man)
    
    app := &APP_global_app
    APP_load_app_A(app)

    for !app.close {
        dt = rl.GetFrameTime()
        total_t = rl.GetTime()

        // input
        APP_update(app)
        APP_draw(app)
        APP_render(&app.render_manager, app.state)

        when ODIN_DEBUG { UTIL_check_tracking_allocator(&APP_tracking_alloc) }

        app.close |= rl.WindowShouldClose()
    }

    log.infof("Exited application loop")

    APP_shutdown()
}

// global shutdown function
APP_shutdown :: proc() {
    CONFIG_save_configs()

    if APP_app_init_flag { APP_destroy_app_D(&APP_global_app) }
    if APP_raylib_init_flag { rl.CloseWindow() }
    if APP_raylib_init_flag { rl.CloseAudioDevice() }

    log.infof("Goodbye")

    if APP_logger_init_flag { log.destroy_file_logger(APP_logger) } 

    UTIL_report_tracking_allocator(&APP_tracking_alloc)
    UTIL_destroy_tracking_allocator_D(&APP_tracking_alloc)

    os.exit(0)
}