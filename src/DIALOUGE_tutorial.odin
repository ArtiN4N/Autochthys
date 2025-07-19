package src

@(rodata)
DIALOUGE_TUTORIAL_MEETING0 := []string{
    "#Hey!#^Over here!",
    "I'm in the corner of the room.^Come talk to me.",
}

@(rodata)
DIALOUGE_TUTORIAL_MEETING1 := []string{
    "...",
    "I never expected to see something like @red<#you#>^here in the pond...",
    "Things would be easier if you were simply #dead#.^ ^With how things are going...^...",
    "I can't imagine @red<#you#>'d be okay with that, however.^ ^If you're looking for a way to escape your @blue<#fate#>,^I hold the key.",
    "You'll have to humor me, though.^This backwater could use some cleaning up...",
    "Within our labrynth you'll find two factions of^parasitic EELs.^They'll be holding two... objects.",
    "I want them.^If you bring those back to me, I'll help you out...",
    "Don't think it'll be easy.^#Good luck.#"
}

@(rodata)
DIALOUGE_TUTORIAL_GENERIC := []string{
    "Good luck...",
}

@(rodata)
DIALOUGE_TUTORIAL_FINISH := []string{
    "Good luck...",
}



DIALOUGE_global_finder_tutorial :: proc(data: ^INTERACTION_NPC_Data) -> ^[]string {
    app := &APP_global_app

    if app.game.item_manager.key_items[.KeyA] > 0 && app.game.item_manager.key_items[.KeyB] > 0 {
        app.should_finish = true
        return &DIALOUGE_TUTORIAL_FINISH
    }

    switch data.talked_to {
    case 1:
        return &DIALOUGE_TUTORIAL_MEETING1
    case 0:
        return &DIALOUGE_TUTORIAL_MEETING0
    }

    return &DIALOUGE_TUTORIAL_GENERIC
}