package src

AI_Types :: union {
    AI_tracker_component,
    AI_lobber_component,
}

AI_Component :: struct {
    type: AI_Types,
    ai_proc: AI_proc_signature,
}

AI_Collection :: [dynamic]AI_Component