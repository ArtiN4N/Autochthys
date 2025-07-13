package src

@(rodata)
DIALOUGE_INTRO := []string{
    "darkness envelops you",
    "...",
    "...",
    "then suddenly, light",
    "...",
    "you see",
    "you see, a reflection^not yours",
    "...",
    "you hear",
    "you hear, clicking, crunching^resonating within your bones",
    "...",
    "you feel",
    "you feel, its chill^its hate",
    "...",
    "you feel, hate^flowing through you",
    "...",
    "you^are^born^of",
    "@red<#sin#>"
}

DIALOUGE_global_finder_intro :: proc() -> ^[]string {
    return &DIALOUGE_INTRO
}