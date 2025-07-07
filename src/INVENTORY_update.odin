package src

import rl "vendor:raylib"

INVENTORY_update :: proc(game: ^Game) {
    GAME_update_cursor(game)

    if rl.IsKeyPressed(.TAB) do TRANSITION_inventory_to_game()
}