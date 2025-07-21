package web_src

import rl "vendor:raylib"
import "base:runtime"
import "core:c"
import "core:mem"
import log "core:log"
import src "../../src"

@(private="file")
web_context: runtime.Context

@export
main_start :: proc "c" () {
	context = runtime.default_context()

	// The WASM allocator doesn't seem to work properly in combination with
	// emscripten. There is some kind of conflict with how the manage memory.
	// So this sets up an allocator that uses emscripten's malloc.
	context.allocator = emscripten_allocator()
	runtime.init_global_temporary_allocator(1*mem.Megabyte)

	// Since we now use js_wasm32 we should be able to remove this and use
	// context.logger = log.create_console_logger(). However, that one produces
	// extra newlines on web. So it's a bug in that core lib.
	context.logger = create_emscripten_logger()

	web_context = context

	rl.InitWindow(src.CONFIG_DEFAULT_SCREEN_WIDTH, src.CONFIG_DEFAULT_SCREEN_HEIGHT, "Autochthys")
    log.infof("Raylib window opened")

    icon := rl.LoadImage("assets/img/icon.png")
    rl.SetWindowIcon(icon)
    rl.UnloadImage(icon)

    rl.SetExitKey(.KEY_NULL)

    rl.InitAudioDevice()
    src.APP_raylib_init_flag = true
    log.infof("Raylib audio opened")

    config_man := &src.APP_global_config_man
    src.CONFIG_init_configs(config_man)
    
    app := &src.APP_global_app
    src.APP_load_app_A(app)
}

@export
main_update :: proc "c" () -> bool {
	context = web_context
    
    //log.infof("hallo!")

    src.dt = rl.GetFrameTime()
    src.total_t = rl.GetTime()

    // input
    src.APP_update(&src.APP_global_app)
    src.APP_draw(&src.APP_global_app)
    src.APP_render(&src.APP_global_app.render_manager, src.APP_global_app.state)

    //log.infof("done cycle!")

    when ODIN_DEBUG { UTIL_check_tracking_allocator(&APP_tracking_alloc) }

    //log.infof("checking should close...")

    //src.APP_global_app.close |= rl.WindowShouldClose()

    //log.infof("rl should close = nope app should close = %v", src.APP_global_app.close)

	return !src.APP_global_app.close
}

@export
main_end :: proc "c" () {
	context = web_context
	src.APP_shutdown()
}

@export
web_window_size_changed :: proc "c" (w: c.int, h: c.int) {
	context = web_context
	//game.parent_window_size_changed(int(w), int(h))
}