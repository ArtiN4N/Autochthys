package src

import rl "vendor:raylib"
import log "core:log"
import strings "core:strings"

FONT_Load_Data :: struct {
    path: string,
    size: i32,
}

FONT_PREFIX_PATH :: "assets/font/"
FONT_POSTFIX_PATH :: ".ttf"

@(rodata)
FONT_paths := [FONT_Tag]FONT_Load_Data{
    .Title48         = {"Roboto_Mono/static/RobotoMono-Bold", 48},
    .UI20            = {"Roboto_Mono/static/RobotoMono-Medium", 20},
    .Dialouge24_reg  = {"Roboto_Mono/static/RobotoMono-Medium", 24},
    .Dialouge24_bold = {"Roboto_Mono/static/RobotoMono-Bold", 24},
}

FONT_Tag :: enum {
    Title48,
    UI20,
    Dialouge24_reg,
    Dialouge24_bold,
}

FONT_Manager :: struct {
    fonts: [FONT_Tag]rl.Font,
}

FONT_load_font_A :: proc(f: ^rl.Font, tag: FONT_Tag) {
    data := FONT_paths[tag]
    str_fpath := UTIL_create_filepath_A(FONT_PREFIX_PATH, data.path, FONT_POSTFIX_PATH)
    filepath := strings.clone_to_cstring(str_fpath)
    f^ = rl.LoadFontEx(filepath, data.size, nil, 0)
    delete(filepath)
    delete(str_fpath)

    if !rl.IsFontValid(f^) {
        log.errorf("Font %v not loaded", tag)
        return
    }
    rl.SetTextureFilter(f.texture, .POINT)
}

FONT_load_manager_A :: proc(man: ^FONT_Manager) {
    for tag in FONT_Tag {
        FONT_load_font_A(&man.fonts[tag], tag)
    }

    log.infof("Font data loaded")
}
FONT_destroy_manager_D :: proc(man: ^FONT_Manager) {
    for tag in FONT_Tag {
        rl.UnloadFont(man.fonts[tag])
    }
    

    log.infof("Font data destroyed")
}

APP_get_global_font :: proc(tag: FONT_Tag) -> ^rl.Font {
    man := &APP_global_app.font_manager
    return &man.fonts[tag]
}