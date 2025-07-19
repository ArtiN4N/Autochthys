package src

MENU_Types :: enum { Menu_main, Menu_savepoint, Menu_main_settings, Menu_Inventory, Menu_Inventory_Stats, Menu_Game_Settings, Menu_instructions }

MENU_setup_proc :: proc(menu: ^Menu)

MENU_setups_A := [MENU_Types]MENU_setup_proc {
    .Menu_main = MENU_setup_main,
    .Menu_savepoint = SAVEPOINT_setup_menu,
    .Menu_main_settings = MENU_setup_main_settings,
    .Menu_Inventory = INVENTORY_setup_menu,
    .Menu_Inventory_Stats = INVENTORY_setup_menu_stats,
    .Menu_Game_Settings = MENU_setup_game_settings,
    .Menu_instructions = MENU_setup_instructions,
}

MENU_destroy_menu_D :: proc(cm: ^Menu) {
    if !cm.created do return

    delete(cm.elements)
}

MENU_set_menu :: proc(cm: ^Menu, type: MENU_Types) {
    MENU_destroy_menu_D(cm)
    MENU_setups_A[type](cm)
}