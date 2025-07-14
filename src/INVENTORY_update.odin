package src

import rl "vendor:raylib"

INVENTORY_update :: proc(game: ^Game) {
    if rl.IsKeyPressed(.TAB) do TRANSITION_set(.Inventory, .Game)

    MENU_update(&APP_global_app.menu)
}