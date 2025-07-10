package src

import rl "vendor:raylib"

// stores the necessary data for an "animation", a collection of sprites tied to a name
ANIMATION_Data :: struct {
    // the position within the sprite sheet, size of a frame of animation in said sheet
    // sprite sheet is determined by the collection that owns the data
    sheet_pos, sheet_size: [2]u16,

    // the offset from the anchor position this animation is being drawn at
    // anchor is owned by the manager that references the collection that owns the data
    anim_center: FVector,

    // determines if the progression of animation frames in the sprite sheet is to the right, or down
    frames_progress_right: bool,
    
    // the number of frames in the animation, and how many of these frames are drawn per second
    frames, fps: u8,

    // the name of the animation, or its "tag" that exists in the collections map of animations
    name: ANIMATION_Tag
}

ANIMATION_create_data :: proc(
    sheet_pos, sheet_size: [2]u16,
    acenter: FVector,
    progress_right: bool,
    frames, fps: u8,
    name: ANIMATION_Tag
) -> (d: ANIMATION_Data) {
    d.sheet_pos = sheet_pos
    d.sheet_size = sheet_size

    d.anim_center = acenter

    d.frames_progress_right = progress_right

    d.frames = frames
    d.fps = fps

    d.name = name

    return d
}