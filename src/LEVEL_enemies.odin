package src

LEVEL_enemies_info :: struct {
    num_enemies: int,
    ids: [dynamic]CONST_Ship_Type,
    spawns: [dynamic][2]i32,
}

LEVEL_create_enemies_info_A :: proc(i: ^LEVEL_enemies_info) {
    i.ids = make([dynamic]CONST_Ship_Type)
    i.spawns = make([dynamic][2]i32)
}

LEVEL_init_enemies_info :: proc(i: ^LEVEL_enemies_info, num: int) {
    i.num_enemies = num
    reserve(&i.ids, num)
    reserve(&i.spawns, num)
}

LEVEL_destroy_enemies_info_D :: proc(i: ^LEVEL_enemies_info) {
    delete(i.ids)
    delete(i.spawns)
}