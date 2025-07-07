package src

AI_Component :: union {
    AI_tracker_component,
    AI_lobber_component,
    AI_follower_component,
}

AI_Wrapper :: struct {
    type: AI_Component,
    ai_proc: AI_proc_signature,
}

AI_Collection :: [dynamic]AI_Wrapper