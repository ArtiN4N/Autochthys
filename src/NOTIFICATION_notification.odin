package src

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"
import rand "core:math/rand"
import strings "core:strings"

NOTIFICATION_LIVE_TIME :: 2
NOTIFICATION_DRIFT_SPEED :: 10
NOTIFICATION_DAMPER :: 0.9

NOTIFICATION_Manager :: struct {
    notis: [dynamic]Notification,
}

NOTIFICATION_manager_create_A :: proc(m: ^NOTIFICATION_Manager) {
    m.notis = make([dynamic]Notification)
}

NOTIFICATION_manager_destroy_D :: proc(m: ^NOTIFICATION_Manager) {
    for &n in &m.notis {
        delete(n.text)
    }
    delete(m.notis)
}

NOTIFICATION_manager_update :: proc(m: ^NOTIFICATION_Manager) {
    i := 0
    for i < len(m.notis) {
        noti := &m.notis[i]
        NOTIFICATION_update(noti)

        if noti.finished {
            delete(noti.text)
            unordered_remove(&m.notis, i)
        } else do i += 1
    }
}

NOTIFICATION_manager_draw :: proc(m: ^NOTIFICATION_Manager) {
    for &n in &m.notis {
        NOTIFICATION_draw(&n)
    }
}

NOTIFICATION_global_add :: proc(t: string, pos: FVector, c: rl.Color, dir: FVector, play_sound: bool = true) {
    nman := &APP_global_app.notification_manager

    text := strings.clone(t)
    append(&nman.notis, NOTIFICATION_create(text, pos, c, dir, play_sound))
}

Notification :: struct {
    text: string,
    position: FVector,
    drift_vec: FVector,
    color: rl.Color,
    elapsed: f32,
    finished: bool,
    new: bool,
    play_sound: bool,
}

NOTIFICATION_create :: proc(t: string, pos: FVector, c: rl.Color, dir: FVector, psound: bool) -> Notification {
    return {
        text = t, position = pos + APP_global_get_render_from_screen_offset(),
        drift_vec = dir * NOTIFICATION_DRIFT_SPEED * (rand.float32() * 0.6 + 0.7),
        color = c,
        elapsed = 0,
        finished = false,
        new = true,
        play_sound = psound
    }
}

NOTIFICATION_update :: proc(n: ^Notification) {
    if n.elapsed >= NOTIFICATION_LIVE_TIME do n.finished = true

    if n.new {
        n.new = false
        if n.play_sound do SOUND_global_fx_choose_noti_sound()
    }

    n.position += n.drift_vec * dt
    // decay
    n.drift_vec *= math.pow(NOTIFICATION_DAMPER, dt)

    n.elapsed += dt
}

NOTIFICATION_draw :: proc(n: ^Notification) {
    if n.finished do return

    font_ptr := APP_get_global_font(.Dialouge24_reg)
    c := n.color

    c.a = u8(50 + 205 * (1 - (n.elapsed / NOTIFICATION_LIVE_TIME)))
    rl.DrawTextEx(font_ptr^, rl.TextFormat("%v", n.text), n.position, 24, MENU_DEFAULT_SPACING, c)
}