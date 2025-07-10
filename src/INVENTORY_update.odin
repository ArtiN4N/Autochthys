package src

import rl "vendor:raylib"

INVENTORY_update :: proc(game: ^Game) {
    GAME_update_cursor(game)

    if rl.IsKeyPressed(.TAB) do TRANSITION_set(.Inventory, .Game)

    if rl.IsKeyPressed(.Q) {
        LEVEL_destroy_world_D(&game.current_world)
        LEVEL_create_world_A(&game.current_world)
    }
}