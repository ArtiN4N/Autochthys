package src

import rl "vendor:raylib"
import math "core:math"
import fmt "core:fmt"

// move hud off render view
GAME_draw_player_hud :: proc(game: ^Game, p: ^Ship, stats: STATS_Player) {
    rw, rh := APP_get_global_render_size()

    hud_margin := 5

    hud_font: f32 = 20

    x := f32(hud_margin)
    y := f32(rh) - 5 - hud_font

    y = GAME_draw_exp_hud(stats, x, y, hud_font, f32(hud_margin))

    x = GAME_draw_hp_hud(p, x, y, hud_font, f32(hud_margin))

    GAME_draw_ammo_hud(p, x, y, hud_font, f32(hud_margin))
    GAME_draw_parry_hud(p, x + hud_font, y - 8, f32(hud_margin))

    GAME_draw_map_hud(game)
}

GAME_draw_map_hud :: proc(game: ^Game) {
    render_man := &APP_global_app.render_manager
    rw, rh := APP_get_global_render_size()
    sw, sh := CONFIG_get_global_screen_size()

    mmap := &game.current_world.minimap
    room := game.level_manager.current_room
    current_room_r := mmap.draw_data.room_rects[int(room)]
    
    ideal_dest_size := FVector{UI_MINIMAP_WIDTH, UI_MINIMAP_HEIGHT}
    mmap_size := FVector{mmap.width, mmap.height}

    scale_x := ideal_dest_size.x / mmap_size.x
    scale_y := ideal_dest_size.y / mmap_size.y
    scale := min(scale_x, scale_y)
    dest_size := mmap_size * scale

    ui_width := f32(sw - rw) / 2
    right_ui_area := f32(sw) - ui_width
    dest_x := ui_width / 2 - dest_size.x / 2

    dest_pos := FVector{right_ui_area + dest_x, dest_x}
    dest := rl.Rectangle{dest_pos.x, dest_pos.y, dest_size.x, dest_size.y}

    spos := FVector{current_room_r.x, current_room_r.y} - FVector{LEVEL_MINIMAP_ROOM_SIZE, LEVEL_MINIMAP_ROOM_SIZE} / 2
    // worst thing ever
    source := rl.Rectangle{
        spos.x - mmap.width / 4 + current_room_r.width,
        -spos.y + mmap.height / 2 + mmap.height / 4 - current_room_r.height,
        mmap.width / 2,
        -mmap.height / 2
    }
    tint := rl.Color{255, 255, 255, 255}

    rl.DrawTexturePro(
        mmap.visualizer.texture,
        source, dest, FVECTOR_ZERO, 0, tint
    )
}

GAME_draw_exp_hud :: proc(stats: STATS_Player, x, y, hud_font, hud_margin: f32) -> (y_off: f32) {
    font := APP_get_global_font(.UI)

    s_man := &APP_global_app.game.stats_manager

    rl.DrawTextEx(font^, rl.TextFormat("lvl %d", s_man.level), {x, y}, hud_font, 2, EXP_COLOR)
    rl.DrawTextEx(font^, rl.TextFormat("%d omega-3", int(s_man.experience)), {x, y - hud_font - hud_margin}, hud_font, 2, EXP_COLOR)
    
    return y - (hud_font + hud_margin)
}

GAME_draw_hp_hud :: proc(p: ^Ship, x, y, hp_bar_size, hud_margin: f32) -> (x_off: f32) {
    total_hp_bars: f32 = 10
    hp_bar_margin: f32 = 1

    stats := &CONST_ship_stats[p.stat_type]

    hp_ratio := p.hp / STATS_global_player_max_hp(stats.base_max_hp)
    draw_hp_bars := int(hp_ratio * total_hp_bars)

    hp_bar := rl.Rectangle{ x, y - hp_bar_size - hud_margin, hp_bar_size, hp_bar_size}

    j := 0
    for i in 0..<total_hp_bars {
        // draw health outline
        rl.DrawRectangleRec(hp_bar, EMPTY_HP_COLOR)
        // draw actual health
        if j < draw_hp_bars { rl.DrawRectangleRec(hp_bar, HP_COLOR) }
        hp_bar.y -= hp_bar_size + hp_bar_margin

        j += 1
    }

    if draw_hp_bars == 0 && p.hp > 0 {
        hp_bar.width /= 2
        rl.DrawRectangleRec(hp_bar, HP_COLOR)
    }

    return hp_bar.x + hp_bar_size + hp_bar_margin * 3
}

GAME_draw_ammo_hud :: proc(p: ^Ship, x, y, ammo_bar_width, hud_margin: f32) {
    draw_ammo_icons := p.gun.ammo
    ammo_bar_height: f32 = 6
    ammo_bar_margin: f32 = 1

    ammo_bar := rl.Rectangle{ x, y - ammo_bar_height - hud_margin, ammo_bar_width - ammo_bar_height, ammo_bar_height}
    ammo_cap := Circle{ x + ammo_bar_width - ammo_bar_height, ammo_bar.y + ammo_bar_height / 2, ammo_bar_height / 2 }

    for i in 0..<draw_ammo_icons {
        rl.DrawCircleV({ammo_cap.x, ammo_cap.y}, ammo_cap.r, AMMO_HUD_ACCENT_COLOR)
        rl.DrawRectangleRec(ammo_bar, AMMO_HUD_COLOR)

        ammo_cap.y -= ammo_bar_height + ammo_bar_margin
        ammo_bar.y -= ammo_bar_height + ammo_bar_margin
    }   

    if draw_ammo_icons <= 0 {
        reload_radius: f32 = 10
        reload_pos := FVector{ammo_bar.x + reload_radius, ammo_bar.y - reload_radius / 2}

        reload_ratio := p.gun.elapsed / p.gun.reload_time
        end_angle := 360 * reload_ratio

        rl.DrawRing(reload_pos, 4, reload_radius, 0, end_angle, 15, AMMO_HUD_COLOR)
    }
    /*
    hp_bar_width: f32 = 6
    hp_bar_margin: f32 = 1
    draw_ammo_icons := p.gun.ammo

    ammo_bar := rl.Rectangle{ x, hud_y + 6, hp_bar_width, hud_height - 6}
    
    */
}

GAME_draw_parry_hud :: proc (s: ^Ship, x, y, hud_margin: f32){
    parry_radius: f32 = 10
    parry_pos := FVector{x + parry_radius, y - parry_radius / 2}

    parry_ratio := min((total_t - s.last_parry_attempt) / PARRY_COOLDOWN_TIME, 1)
    end_angle := 360 * parry_ratio

    rl.DrawRing(parry_pos, 4, parry_radius, 0, f32(end_angle), 15, PARRY_BULLET_COLOR)
}