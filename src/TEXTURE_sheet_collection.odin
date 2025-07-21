package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"
import strings "core:strings"

TEXTURE_load_sheet_collections_A :: proc(collection: ^TEXTURE_Sheet_Collection) {
    for sheet in ANIMATION_Entity_Type {
        // First we check if the sheet in the array is already a texture
        // if it is, that means it should already be loaded, and we have an error
        _, is_texture := collection[sheet].(rl.Texture2D)

        if is_texture {
            log.logf(.Warning, "Tried to load already loaded texture sheet %v", sheet)
            return
        }

        // Now we are sure that the texture data was nil, and we can make it a Texture2D type
        collection[sheet] = rl.Texture2D{}

        texture_addr := &collection[sheet].(rl.Texture2D)

        file_path := UTIL_create_filepath_A(TEXTURE_SHEET_BASE_PATH, TEXTURE_Sheet_Names[sheet], TEXTURE_SHEET_BASE_EXT)
        cfile_path := strings.clone_to_cstring(file_path)

        texture_addr^ = rl.LoadTexture(cfile_path)

        delete(cfile_path)
        delete(file_path)
    }

    log.infof("Textures loaded")
}

TEXTURE_destroy_sheet_collections_D :: proc(collection: ^TEXTURE_Sheet_Collection) {
    for sheet in ANIMATION_Entity_Type {
        // First we check if the sheet in the array is already a texture
        // if it isnt, that means it isnt loaded, and thus cannot be unloaded
        _, is_texture := collection[sheet].(rl.Texture2D)

        if !is_texture {
            log.logf(.Warning, "Tried to unload texture sheet %v which is not loaded", sheet)
            return
        }

        texture_addr := &collection[sheet].(rl.Texture2D)

        rl.UnloadTexture(texture_addr^)

        // finally we set specific sheet in the collection array back to nil
        collection[sheet] = nil
    }
}

// returns a pointer to keep stack size low, since a texture could have a crazy amount of data
TEXTURE_get_global_sheet :: proc(sheet: ANIMATION_Entity_Type) -> ^rl.Texture2D {
    collection := &APP_global_app.texture_collection
    // First we check if the sheet in the array is already a texture
    // if it isnt, that means it isnt loaded, and thus cannot be referenced
    _, is_texture := collection[sheet].(rl.Texture2D)

    if !is_texture {
        log.logf(.Fatal,
            "Trying to access texture sheet %v that does not exist",
            sheet,
        )
        panic("see log")
    }

    texture_addr := &collection[sheet].(rl.Texture2D)

    return texture_addr
}