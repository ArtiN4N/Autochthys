package src

LEVEL_Room :: struct {
    tag: LEVEL_Tag,
    collision: [LEVEL_WIDTH][LEVEL_HEIGHT]bool,
    aggresion: bool,
    enemy_info: [dynamic]LEVEL_room_enemy_info,
    warps: [LEVEL_Room_Connection]LEVEL_Room_World_Index,
}