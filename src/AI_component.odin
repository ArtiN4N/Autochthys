package src

AI_Component :: union {
    AI_tracker_component,
    AI_lobber_component,
    AI_follower_component,
    AI_octopus_component,
}

AI_NUM :: 4

AI_Wrapper :: struct {
    type: AI_Component,
    ai_proc: AI_proc_signature,

    ai_for_sid: int,
    tracked_sid: int,

    delay: f32,
    seen: bool,
}

AI_Collection :: [dynamic]AI_Wrapper