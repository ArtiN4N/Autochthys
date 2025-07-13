package src

INTRO_global_selection_event :: proc(boon: cstring)

INTRO_global_selection :: proc(idx: int, boon: cstring) {
    INTRO_global_destroy_intro_state_D(&APP_global_app)
    INTRO_selection_events[idx](boon)

    APP_global_app.game.stats_manager.boon_title = boon
}

INTRO_selection_events := [7]INTRO_global_selection_event{
    INTRO_selection_gluttony,
    INTRO_selection_greed,
    INTRO_selection_pride,
    INTRO_selection_envy,
    INTRO_selection_wrath,
    INTRO_selection_sloth,
    INTRO_selection_lust,
}

INTRO_selection_gluttony :: proc(boon: cstring) {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_greed :: proc(boon: cstring) {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_pride :: proc(boon: cstring) {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_envy :: proc(boon: cstring) {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_wrath :: proc(boon: cstring) {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_sloth :: proc(boon: cstring) {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_lust :: proc(boon: cstring) {
    TRANSITION_set(.Intro, .Game)
}