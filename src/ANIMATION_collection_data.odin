package src
import fmt "core:fmt"

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
            name = .ANIMATION_IDLE_TAG
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
            name = .ANIMATION_IDLE_TAG
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
            name = .ANIMATION_IDLE_TAG
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
            name = .ANIMATION_IDLE_TAG
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
            name = .ANIMATION_IDLE_TAG
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
            name = .ANIMATION_IDLE_TAG
        )
    )
}

ANIMATION_create_item_collections :: proc(list: ^ANIMATION_Master_Collections) {
    standard_fps: u8 = 12
    sheet_scale: f32 = 1
    ent_type: ANIMATION_Entity_Type = .ITEM_Giver
    
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {48,48},
            acenter = {24,24},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = .ANIMATION_IDLE_TAG
        )
    )

    ent_type = .ITEM_Key
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {48,18},
            acenter = {24,9},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = .ANIMATION_IDLE_TAG
        )
    )
}

ANIMATION_create_npc_collections :: proc(list: ^ANIMATION_Master_Collections) {
    standard_fps: u8 = 12
    sheet_scale: f32 = 1
    ent_type: ANIMATION_Entity_Type = .Tutorial
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {48,48},
            acenter = {24,24},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = .ANIMATION_IDLE_TAG
        )
    )


    ent_type = .Interact
    sheet_scale = 3
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 0},
            sheet_size = {10,10},
            acenter = {5,5},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = .ANIMATION_IDLE_TAG
        )
    )



    ent_type = .Savepoint
    sheet_scale = 0.5
    list[ent_type] = ANIMATION_create_collection(sheet_scale, ent_type)

    // IDLE ANIMATION
    ANIMATION_add_data_to_master_list(list, ent_type,
        ANIMATION_create_data(
            sheet_pos = {0, 400},
            sheet_size = {62,112},
            acenter = {31,56},
            progress_right = true,
            frames = 1,
            fps = standard_fps,
            name = .ANIMATION_IDLE_TAG
        )
    )
}