package src

ANIMATION_create_player_collection :: proc(list: ^ANIMATION_Master_Collections) {
    ent_type: ANIMATION_Entity_Type = .Player

    list[ent_type] = ANIMATION_create_collection(2, ent_type)

    standard_fps: u8 = 8

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 32},
            sheet_size = {32, 32},
            anchor_offset = {0, -6},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = ANIMATION_IDLE_TAG
        )
    )
}