package src

import rl "vendor:raylib"
import log "core:log"
import fmt "core:fmt"
import rand "core:math/rand"

Menu :: struct {
    elements: [dynamic]MENU_Element,
    y_margin: f32,
    x_margin: f32,
    top_left: FVector,
    size: FVector,
    color: rl.Color,
    created: bool,

    type: MENU_Types,
    water_sim: MENU_Water,
}

MENU_WATER_COL_LINES :: 43

MENU_init_water_sim :: proc(menu: ^Menu) {
    menu.water_sim.collision_lines = {
        {{108, 206}, {126, 146}},
        {{126, 146}, {142, 146}},
        {{142, 146}, {160, 206}},
        {{178, 207}, {171, 199}},
        {{171, 199}, {170, 162}},
        {{170, 162}, {184, 162}},
        {{184, 162}, {184, 195}},
        {{184, 195}, {200, 189}},
        {{200, 189}, {200, 162}},
        {{200, 162}, {213, 162}},
        {{213, 162}, {213, 206}},
        {{226, 173}, {226, 162}},
        {{226, 162}, {240, 162}},
        {{240, 162}, {240, 147}},
        {{240, 147}, {253, 147}},
        {{253, 147}, {253, 162}},
        {{253, 162}, {270, 162}},
        {{270, 162}, {270, 174}},
        {{285, 178}, {301, 162}},
        {{301, 162}, {315, 162}},
        {{315, 162}, {331, 178}},
        {{343, 178}, {363, 162}},
        {{363, 162}, {374, 162}},
        {{374, 162}, {389, 168}},
        {{403, 206}, {403, 141}},
        {{403, 141}, {416, 141}},
        {{416, 141}, {416, 169}},
        {{416, 169}, {445, 169}},
        {{458, 174}, {458, 162}},
        {{458, 162}, {502, 162}},
        {{519, 206}, {519, 141}},
        {{519, 141}, {532, 141}},
        {{532, 141}, {532, 169}},
        {{532, 169}, {561, 169}},
        {{573, 228}, {573, 217}},
        {{573, 217}, {595, 217}},
        {{595, 217}, {573, 162}},
        {{573, 162}, {588, 162}},
        {{588, 162}, {598, 192}},
        {{598, 192}, {609, 162}},
        {{609, 162}, {623, 162}},
        {{636, 172}, {674, 172}},
        {{636, 196}, {669, 198}},
    }
    menu.water_sim.base_height = -100
    menu.water_sim.starting_droplets_num = 0
    menu.water_sim.starting_droplets_max = 300

    for i in 0..<MENU_WATER_WIDTH {
        menu.water_sim.water[i] = 1
        menu.water_sim.vel[i] = 0
        menu.water_sim.accel[i] = 0
        
    }

    for i in 0..<MENU_WATER_DROP_WIDTH {
        menu.water_sim.droplet_heights[i] = 770
    }
}

MENU_WATER_WIDTH :: 768
MENU_WATER_DROP_WIDTH :: 768 + 200

MENU_Water :: struct {
    base_height: f32,
    water: [MENU_WATER_WIDTH]f32,
    vel: [MENU_WATER_WIDTH]f32,
    accel: [MENU_WATER_WIDTH]f32,

    droplet_heights: [MENU_WATER_DROP_WIDTH]f32,
    starting_droplets_max: int,
    starting_droplets_num: int,

    collision_lines: [MENU_WATER_COL_LINES]Line,
}

MENU_update_waves :: proc(menu: ^Menu) {
    if menu.water_sim.base_height > 800 do return

    //if menu.water_sim.base_height < 800 do menu.water_sim.base_height += 50 * dt

    if menu.water_sim.starting_droplets_num < menu.water_sim.starting_droplets_max {

        for _ in 0..<1 {
            droplet_start := rand.int_max(MENU_WATER_DROP_WIDTH)
            droplet_idx := droplet_start
            finish_start := false

            for !finish_start {
                if menu.water_sim.droplet_heights[droplet_idx] > 769 {
                    
                    menu.water_sim.droplet_heights[droplet_idx] = 768
                    menu.water_sim.starting_droplets_num += 1
                    finish_start = true
                    break
                } else {
                    droplet_idx += 1
                    if droplet_idx >= MENU_WATER_DROP_WIDTH do droplet_idx = 0
                }

                if droplet_idx == droplet_start {
                    menu.water_sim.starting_droplets_num = menu.water_sim.starting_droplets_max
                    break
                }
            }
        }
        
    }
    
    for i in 0..<MENU_WATER_DROP_WIDTH {
        if menu.water_sim.droplet_heights[i] > 769 do continue
        
        menu.water_sim.droplet_heights[i] -= 1200 * dt

        for l in menu.water_sim.collision_lines {
            spos := FVector{f32(i) - 100, 768 - menu.water_sim.droplet_heights[i]}
            epos := spos + {0, 5}

            x_drift := 100 * (spos.y / 768)
            spos.x += x_drift
            epos.x += x_drift + 1

            if lines_collide(l, {spos, epos}) {
                menu.water_sim.droplet_heights[i] = 768
            }
        }

        if menu.water_sim.droplet_heights[i] < menu.water_sim.base_height - 1 {
            menu.water_sim.droplet_heights[i] = 768
            //menu.water_sim.starting_droplets_num -= 1
            menu.water_sim.base_height += f32(2.0 / 192.0)

            if i < MENU_WATER_WIDTH {
                force: f32 = 5
                menu.water_sim.vel[i] += force
                if i > 0 do menu.water_sim.vel[i - 1] += force * 0.5
                if i < MENU_WATER_WIDTH-1 do menu.water_sim.vel[i + 1] += force * 0.5
            }
            
        }
    }

    tension : f32 = 0.025
    dampening : f32 = 0.025
    spread : f32 = 0.25

    for i in 0..<MENU_WATER_WIDTH {
        force := tension * (menu.water_sim.water[i] - 1)

        menu.water_sim.accel[i] = -force - menu.water_sim.vel[i] * dampening
        menu.water_sim.vel[i] += menu.water_sim.accel[i]
        menu.water_sim.water[i] += menu.water_sim.vel[i]
    }

    left_deltas := [MENU_WATER_WIDTH]f32{}
    right_deltas := [MENU_WATER_WIDTH]f32{}

    // 8 passes
    for j in 0..<8 {
        for i in 1..<MENU_WATER_WIDTH - 1 {
            left_deltas[i] = spread * (menu.water_sim.water[i] - menu.water_sim.water[i - 1])
            right_deltas[i] = spread * (menu.water_sim.water[i] - menu.water_sim.water[i + 1])
        }

        for i in 1..<MENU_WATER_WIDTH - 1 {
            menu.water_sim.vel[i - 1] += left_deltas[i]
            menu.water_sim.vel[i + 1] += right_deltas[i]
        }

        for i in 1..<MENU_WATER_WIDTH - 1 {
            menu.water_sim.water[i - 1] += left_deltas[i]
            menu.water_sim.water[i + 1] += right_deltas[i]
        }
    }
}

MENU_update :: proc(menu: ^Menu) {
    if !menu.created {
        log.warnf("Trying to update non-created menu")
        return
    }

    should_rain := menu.type == .Menu_main || menu.type == .Menu_main_settings || menu.type == .Menu_main_credits || menu.type == .Menu_instructions1 || menu.type == .Menu_instructions2
    if should_rain {
        MENU_update_waves(menu)
    }

    menu_position := menu.top_left + FVector{menu.x_margin, menu.y_margin}
    for &ele in &menu.elements {
        menu_position.y = MENU_update_element(&ele, menu_position)
        menu_position.y += menu.y_margin
    }
}

MENU_draw_waves :: proc(menu: ^Menu) {
    for i in 0..<MENU_WATER_DROP_WIDTH {
        if menu.water_sim.droplet_heights[i] <= 769 {
            spos := FVector{f32(i) - 100, 768 - menu.water_sim.droplet_heights[i]}
            epos := spos + {0, 15}

            x_drift := 100 * (spos.y / 768)
            spos.x += x_drift
            epos.x += x_drift + 3

            rl.DrawLineV(spos, epos, WHITE_COLOR)
        }

        
    }

    for i in 0..<MENU_WATER_WIDTH {
        height := menu.water_sim.base_height + menu.water_sim.water[i]
        rl.DrawRectangleRec({f32(i), 768 - height, 1, height}, BLACK_COLOR)
    }
}

MENU_draw :: proc(menu: ^Menu) {
    if !menu.created {
        log.warnf("Trying to draw non-created menu")
        return
    }

    rl.DrawRectangleV(menu.top_left, menu.size, menu.color)

    should_rain := menu.type == .Menu_main || menu.type == .Menu_main_settings || menu.type == .Menu_main_credits || menu.type == .Menu_instructions1 || menu.type == .Menu_instructions2
    if should_rain {
        MENU_draw_waves(menu)
    }

    menu_position := menu.top_left + FVector{menu.x_margin, menu.y_margin}
    for &ele in &menu.elements {
        menu_position.y = MENU_draw_element(&ele, menu_position)
        menu_position.y += menu.y_margin
    }
}

MENU_state_draw :: proc(render_man: ^APP_Render_Manager, app: ^App) {
    rl.BeginTextureMode(render_man.menu)
    defer rl.EndTextureMode()

    rl.ClearBackground(APP_RENDER_CLEAR_COLOR)

    MENU_draw(&app.menu)
    OTHER_draw_ui(render_man)
}