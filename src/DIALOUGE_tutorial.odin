package src

@(rodata)
DIALOUGE_TUTORAIL_MEETING0 := []string{
    "*Hey!*^Over here!",
    "I'm in the corner of the room.^Come talk to me.",
}

@(rodata)
DIALOUGE_TUTORAIL_MEETING1 := []string{
    "This is my *second* dialouge...",
    "*This* is my *third* dialouge!!",
    "IM GONNA @red<KILL> YOU",
    "im am you're @blue<friend>",
    "i am...^*@blue<tutorail..>*"
}

@(rodata)
DIALOUGE_TUTORAIL_GENERIC := []string{
    "Good luck...",
}



DIALOUGE_global_finder_tutorial :: proc(data: ^INTERACTION_NPC_Data) -> ^[]string {
    app := &APP_global_app

    switch data.talked_to {
    case 1:
        return &DIALOUGE_TUTORAIL_MEETING1
    case 0:
        return &DIALOUGE_TUTORAIL_MEETING0
    }

    return &DIALOUGE_TUTORAIL_GENERIC
}