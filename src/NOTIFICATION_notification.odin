package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"
import rand "core:math/rand"

NOTIFICATION_LIVE_TIME :: 1
NOTIFICATION_DRIFT_SPEED :: 20
NOTIFICATION_DAMPER :: 0.9

NOTIFICATION_Manager :: struct {
    notis: [dynamic]Notification,
}

NOTIFICATION_manager_create_A :: proc(m: ^NOTIFICATION_Manager) {
    m.notis = make([dynamic]Notification)
}

NOTIFICATION_manager_destroy_D :: proc(m: ^NOTIFICATION_Manager) {
    delete(m.notis)
}

NOTIFICATION_manager_update :: proc(m: ^NOTIFICATION_Manager) {
    i := 0
    for i < len(m.notis) {
        noti := &m.notis[i]
        NOTIFICATION_update(noti)

        if noti.finished {
            unordered_remove(&m.notis, i)
        } else do i += 1
    }
}

NOTIFICATION_manager_draw :: proc(m: ^NOTIFICATION_Manager) {
    for &n in &m.notis {
        NOTIFICATION_draw(&n)
    }
}

NOTIFICATION_global_add :: proc(t: string, pos: FVector, c: rl.Color, dir: FVector) {
    nman := &APP_global_app.notification_manager

    append(&nman.notis, NOTIFICATION_create(t, pos, c, dir))
}

Notification :: struct {
    text: string,
    position: FVector,
    drift_vec: FVector,
    color: rl.Color,
    elapsed: f32,
    finished: bool,
}

NOTIFICATION_create :: proc(t: string, pos: FVector, c: rl.Color, dir: FVector) -> Notification {
    return {
        text = t, position = pos + APP_global_get_render_from_screen_offset(),
        drift_vec = dir * NOTIFICATION_DRIFT_SPEED * (rand.float32() * 0.6 + 0.7),
        color = c,
        elapsed = 0,
        finished = false
    }
}

NOTIFICATION_update :: proc(n: ^Notification) {
    if n.elapsed >= NOTIFICATION_LIVE_TIME do n.finished = true

    n.position += n.drift_vec * dt
    // decay
    n.drift_vec *= math.pow(NOTIFICATION_DAMPER, dt)

    n.elapsed += dt
}

NOTIFICATION_draw :: proc(n: ^Notification) {
    if n.finished do return

    font_ptr := APP_get_global_font(.Dialouge24_reg)
    rl.DrawTextEx(font_ptr^, rl.TextFormat("%v", n.text), n.position, 24, MENU_DEFAULT_SPACING, n.color)
}