package src

OUTRO_global_selection_event :: proc()

OUTRO_selection_events := [2]OUTRO_global_selection_event{
    OUTRO_yes,
    OUTRO_no,
}

OUTRO_yes :: proc() {
    TRANSITION_set(.Outro, .Menu)
}
OUTRO_no :: proc() {
    APP_shutdown()
}