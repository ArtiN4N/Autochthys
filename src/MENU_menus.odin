package src

MENU_Types :: enum { Menu_main, Menu_savepoint }

MENU_setup_proc :: proc(menu: ^Menu)

MENU_setups_A := [MENU_Types]MENU_setup_proc {
    .Menu_main = MENU_setup_main,
    .Menu_savepoint = SAVEPOINT_setup_menu,
}

MENU_destroy_menu_D :: proc(cm: ^Menu) {
    if !cm.created do return

    delete(cm.elements)
}

MENU_set_menu :: proc(cm: ^Menu, type: MENU_Types) {
    MENU_destroy_menu_D(cm)
    MENU_setups_A[type](cm)
}