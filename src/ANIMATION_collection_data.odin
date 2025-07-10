package src

ANIMATION_create_koi_collections :: proc(list: ^ANIMATION_Master_Collections) {
    //BODY
    standard_fps: u8 = 12
    sheet_scale: f32 = 1
    ent_type: ANIMATION_Entity_Type = .Koi
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {28, 60},
            acenter = {13.5, 20},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = ANIMATION_IDLE_TAG
        )
    )

    ent_type = .Koi_fin
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {28, 60},
            acenter = {13.5, 20},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = ANIMATION_IDLE_TAG
        )
    )

    ent_type = .Koi_tail
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {28, 60},
            acenter = {13.5, 20},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = ANIMATION_IDLE_TAG
        )
    )
}


ANIMATION_create_minnow_collections :: proc(list: ^ANIMATION_Master_Collections) {
    //BODY
    standard_fps: u8 = 12
    sheet_scale: f32 = 2
    ent_type: ANIMATION_Entity_Type = .Minnow
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {10, 26},
            acenter = {4.5, 9},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = ANIMATION_IDLE_TAG
        )
    )

    ent_type = .Minnow_fin
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {10, 26},
            acenter = {4.5, 9},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = ANIMATION_IDLE_TAG
        )
    )

    ent_type = .Minnow_tail
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {10, 26},
            acenter = {4.5, 9},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = ANIMATION_IDLE_TAG
        )
    )
}