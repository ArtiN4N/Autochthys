package src

import rl "vendor:raylib"
import log "core:log"

FONT_Manager :: struct {
    default: rl.Font,
    bold: rl.Font,
}

FONT_load_manager_A :: proc(man: ^FONT_Manager) {
    man.default = rl.LoadFontEx("assets/font/Roboto_Mono/static/RobotoMono-Regular.ttf", 40, nil, 0)
    if !rl.IsFontValid(man.default) {
        log.errorf("Default font not loaded")
    }
    rl.SetTextureFilter(man.default.texture, .POINT)

    man.bold = rl.LoadFontEx("assets/font/Roboto_Mono/static/RobotoMono-Bold.ttf", 40, nil, 0)
    if !rl.IsFontValid(man.bold) {
        log.errorf("Default font not loaded")
    }
    rl.SetTextureFilter(man.bold.texture, .POINT)

    log.infof("Font data loaded")
}
FONT_destroy_manager_D :: proc(man: ^FONT_Manager) {
    rl.UnloadFont(man.default)

    log.infof("Font data destroyed")
}

APP_get_global_default_font :: proc(bold: bool = false) -> ^rl.Font {
    man := &APP_global_app.font_manager
    if bold do return &man.bold
    else do return &man.default
}