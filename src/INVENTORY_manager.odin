package src

INVENTORY_PAGE :: enum { Map = 0, Items, Stats, Quests }

INVENTORY_Manager :: struct {
    cur_page: INVENTORY_PAGE,
}

INVENTORY_create_manager :: proc(man: ^INVENTORY_Manager) {
    man.cur_page = .Map
}

INVENTORY_global_set_page :: proc(page: INVENTORY_PAGE) {
    APP_global_app.game.inventory_manager.cur_page = page
}