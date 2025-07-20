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
    "Within our labrynth you'll find a faction of^parasitic EELs.^They'll be holding an... object.",
    "I want it.^If you bring it back to me, I'll help you out...",
    "Don't think it'll be easy.^#Good luck.#"
}

@(rodata)
DIALOUGE_TUTORIAL_GENERIC := []string{
    "Good luck...",
}

@(rodata)
DIALOUGE_TUTORIAL_HALF := []string{
    "...",
    "So you cleaned out some eels...^I'm suprised...",
    "Your job isn't finished yet, however.^There is another faction, with yet another... object.",
    "I wanted both. Did I not mention that?",
    "Now now, don't get angry.^Humor me, and I'll make it worth your while.^We both know you can't complete your task alone...",
    "Struggler! Find the second faction and bring them down.^Return to me with the second piece of the puzzle..."
}

@(rodata)
DIALOUGE_TUTORIAL_HALF_AGAIN := []string{
    "Struggler! Find the second faction and bring them down.^Return to me with the second piece of the puzzle..."
} 


@(rodata)
DIALOUGE_TUTORIAL_FINISH := []string{
    "...",
    "...",
    "And so, it is complete.",
    "For a fish of your size...^No, I suppose you're not even a fish anymore...",
    "Very well. I will aide you.",
    "I have to warn you... Or perhaps you already know.^Your resistance is futile. Your task impossible.",
    "Going against that... nothing good can come of it.^Though I suppose, nothing good can come from you as you are now, either...",
    "I will open the path. Go, and don't look back.",
    "Good luck... struggler.",
}



DIALOUGE_global_finder_tutorial :: proc(data: ^INTERACTION_NPC_Data) -> ^[]string {
    app := &APP_global_app

    both := app.game.item_manager.key_items[.KeyA] > 0 && app.game.item_manager.key_items[.KeyB] > 0
    either := app.game.item_manager.key_items[.KeyA] > 0 || app.game.item_manager.key_items[.KeyB] > 0
    if !both && either {
        if !data.either_flagged {
            data.either_flagged = true
            return &DIALOUGE_TUTORIAL_HALF
        }
        return &DIALOUGE_TUTORIAL_HALF_AGAIN
    } else if both {
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