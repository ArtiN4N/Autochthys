package src

import rl "vendor:raylib"

// App state is what the application is currently doing
// can be three values: game, menu and transition
// menu and game are self explanitory
// transition moves between one state to another

// We use a union of structs here to simulate an enum, so that we can include some state specific data
// like transition data for the transition state
APP_State :: union{ APP_Game_State, APP_Menu_State, APP_Transition_State, APP_Debug_State }

// functional state just includes states that have functional behaviour in the application
// is used by the transition state to determine what to show to the screen
APP_Functional_State :: enum{ Game, Menu }

APP_Game_State :: struct {}
APP_Menu_State :: struct {}

// provides debugging / testing tools
APP_Debug_State :: struct {
    original_state: APP_Functional_State,
}

// Transition state has transitions from a functional state to another
// and lasts a specified amount of time
APP_Transition_State :: struct {
    from, to: APP_Functional_State,
    time, elapsed: f32,
    level_from: LEVEL_Tag,
    warp_dir: FVector,
}

APP_create_transition_state :: proc(from, to: APP_Functional_State, time: f32, lfrom: LEVEL_Tag = .Debug_L00, wdir: FVector = FVECTOR_ZERO) -> APP_Transition_State {
    return {
        from = from,
        to = to,
        time = time,
        elapsed = 0,
        level_from = lfrom,
        warp_dir = wdir
    }
}