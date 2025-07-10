package src

import rl "vendor:raylib"
import fmt "core:fmt"
import log "core:log"

// Each entity instance has an animation ANIMATION_Manager, which can grab animation frames (rects)
// from a referenced collection of animation data, and display the desired image
ANIMATION_Manager :: struct {
    collection: ^ANIMATION_Collection,

    elapsed: f32,
    current_anim: string,
    current_frame: u8
}

ANIMATION_create_manager :: proc(
    c: ^ANIMATION_Collection,
) -> (e: ANIMATION_Manager){
    e.collection = c

    e.elapsed = 0
    e.current_anim = ANIMATION_IDLE_TAG
    e.current_frame = 1

    return e
}

// gets the current animation and the frame number
// we use this as a wrapper to check for errors each time
ANIMATION_get_data_and_frame :: proc(
    e_man: ^ANIMATION_Manager
)-> (animation: ^ANIMATION_Data, frame: u8) {
    if e_man.collection == nil {
        log.logf(.Fatal,
            "Entity animation ANIMATION_Manager %v is missing a collection",
            e_man^
        )
        panic("FATAL crash! See log file for info.")
    }

    animation_map: ^map[string]ANIMATION_Data = &e_man.collection.animations
    
    if !(e_man.current_anim in animation_map) {
        log.logf(.Fatal,
            "Trying to draw animation %v from collection of type %v that does not exist",
            e_man.current_anim, e_man.collection.entity_type
        )
        panic("FATAL crash! See log file for info.")
    }

    animation = &animation_map[e_man.current_anim]

    if e_man.current_frame > animation.frames {
        log.logf(.Fatal,
            "Trying to draw animation frame #%v from animation %v with only #%v frames",
            e_man.current_frame, animation^, animation.frames
        )
        panic("FATAL crash! See log file for info.")
    }

    frame = e_man.current_frame

    return animation, frame
}

// should move these next 2 functions to animation data file and clean them up

ANIMATION_manager_get_src_frame :: proc(e_man: ^ANIMATION_Manager) -> Rect {
    animation, frame := ANIMATION_get_data_and_frame(e_man)
    return ANIMATION_get_src_frame(animation, frame)
}

ANIMATION_manager_get_dest_frame :: proc(e_man: ^ANIMATION_Manager, anchor_rect: Rect) -> Rect {
    animation, frame := ANIMATION_get_data_and_frame(e_man)
    return ANIMATION_get_dest_frame(animation, frame, e_man.collection.sheet_scale, anchor_rect)
}

ANIMATION_manager_get_dest_origin :: proc(e_man: ^ANIMATION_Manager, dest: rl.Rectangle) -> FVector {
    animation, frame := ANIMATION_get_data_and_frame(e_man)
    
    return animation.anim_center * e_man.collection.sheet_scale
}

// The src frame is the rectangle within the sprite sheet that is to be drawn in the game
ANIMATION_get_src_frame :: proc(animation: ^ANIMATION_Data, frame: u8) -> Rect {
    frame := frame
    // first frame uses first offset position, meaning we want to multiply offset by 0
    // but frames are 1 indexed
    frame -= 1

    sheet_pos_f := FVector{ f32(animation.sheet_pos.x), f32(animation.sheet_pos.y) }
    sheet_size_f := FVector{ f32(animation.sheet_size.x), f32(animation.sheet_size.y) }

    // we have to calculate where on the sprite sheet we grab from
    // this depends on the current frame of animation
    // we start at the specified sheet pos, or the starting pos,
    // and then use the current frame number to calculate how far we offset from that
    current_frame_offset := FVECTOR_ZERO
    if animation.frames_progress_right {
        // as we progress animation, frames are located to the right
        current_frame_offset.x = f32(frame) * sheet_size_f.x
    } else {
        // frames are located below
        current_frame_offset.y = f32(frame) * sheet_size_f.y
    }

    src_pos := sheet_pos_f + current_frame_offset
    src_size := sheet_size_f
    src := rect_from_vecs(src_pos, src_size)

    return src
}

// the dest frame is the rectangle where the src frame is drawn to "on screen"
// instead of drawing to a rectangle, we use the sheet scale to scale up the src rectangle,
// and then place the src center at the anchor center
ANIMATION_get_dest_frame :: proc(
    animation: ^ANIMATION_Data, frame: u8, scale: f32,
    anchor: Rect,
    flip_x_offset: bool = false
) -> Rect {
    frame := frame

    sheet_pos_f := FVector{ f32(animation.sheet_pos.x), f32(animation.sheet_pos.y) }
    sheet_size_f := FVector{ f32(animation.sheet_size.x), f32(animation.sheet_size.y) }

    // scale the sheet frame size by the collections (entities) sheet scale
    dest_size := sheet_size_f * scale

    // find the center of the anchored rectangle
    anchor_center := get_rect_pos(anchor) + get_rect_size(anchor) / 2

    // displace by size of dest rect (centers dest rect)
    //animation_center := animation.anim_center - dest_size / 2

    // each animation also has its own offset, to avoid having to make all animations centered around the subject
    // the offset should be scaled up, since offsets should be calculated using the base animation size
    //anchor_offset := FVector{ f32(animation.anchor_offset.x), f32(animation.anchor_offset.y) }
    //scaled_offset := anchor_offset * scale
    //if flip_x_offset { scaled_offset.x *= -1 }

    dest_pos := anchor_center
    dest := rect_from_vecs(dest_pos, dest_size)

    return dest
}

ANIMATION_set_manager_anim :: proc(e_man: ^ANIMATION_Manager, anim: string) {
    animation_map: ^map[string]ANIMATION_Data = &e_man.collection.animations
    if !(anim in animation_map) {
        log.logf(.Fatal,
            "Trying to set ANIMATION_Manager to animation %v from collection of type %v that does not exist",
            anim, e_man.collection.entity_type
        )
        panic("FATAL crash! See log file for info.")
    }

    e_man.current_anim = anim

    e_man.elapsed = 0
    e_man.current_frame = 1
}

// right now, on the first frame that the animation is active, were adding dt to elapsed
// but dt is the time since last frame
// meaning that its as if were counting the previous frame for the time of the first frame
// even though it was not active then
ANIMATION_update_manager :: proc(e_man: ^ANIMATION_Manager) {
    e_man.elapsed += dt
    
    animation, frame := ANIMATION_get_data_and_frame(e_man)
    // turn frames per second into seconds per frame
    spf := 1 / f32(animation.fps)

    if e_man.elapsed >= spf {
        e_man.current_frame += 1
        e_man.elapsed = 0
    }

    if e_man.current_frame > animation.frames {
        e_man.current_frame = 1
    }
}

ANIMATION_manager_match_manager :: proc(main, child: ^ANIMATION_Manager) {
    child.current_anim = main.current_anim
    child.current_frame = main.current_frame
    child.elapsed = main.elapsed
}