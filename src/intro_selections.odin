package src

INTRO_global_selection_event :: proc()

INTRO_selection_events := [7]INTRO_global_selection_event{
    INTRO_selection_gluttony,
    INTRO_selection_greed,
    INTRO_selection_pride,
    INTRO_selection_envy,
    INTRO_selection_wrath,
    INTRO_selection_sloth,
    INTRO_selection_lust,
}

INTRO_selection_gluttony :: proc() {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_greed :: proc() {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_pride :: proc() {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_envy :: proc() {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_wrath :: proc() {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_sloth :: proc() {
    TRANSITION_set(.Intro, .Game)
}
INTRO_selection_lust :: proc() {
    TRANSITION_set(.Intro, .Game)
}