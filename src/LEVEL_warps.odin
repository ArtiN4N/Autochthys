package src

LEVEL_warps_info :: struct {
    warp_tos: map[[2]i32]LEVEL_Tag,
}

LEVEL_init_warps_info_A :: proc(i: ^LEVEL_warps_info) {
    i.warp_tos = make(map[[2]i32]LEVEL_Tag)
}

LEVEL_destroy_warps_info_D :: proc(i: ^LEVEL_warps_info) {
    delete(i.warp_tos)
}