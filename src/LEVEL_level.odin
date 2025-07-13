package src

import rl "vendor:raylib"
import os "core:os"
import log "core:log"
import fmt "core:fmt"
import rand "core:math/rand"
import strconv "core:strconv"
import strings "core:strings"

LEVEL_COLLISION_MAP_SPLIT_AFTER :: LEVEL_WIDTH*(LEVEL_HEIGHT/2)

LEVEL_Collision :: struct {
    top: bit_set[0..<LEVEL_WIDTH*(LEVEL_HEIGHT/2)],
    bot: bit_set[LEVEL_WIDTH*(LEVEL_HEIGHT/2)..<LEVEL_WIDTH*LEVEL_HEIGHT],
}

LEVEL_set_index_collision :: proc(c: ^LEVEL_Collision, x, y: int, set: bool) {
    idx := x + y * LEVEL_WIDTH
    if set {
        if idx < LEVEL_COLLISION_MAP_SPLIT_AFTER do c.top += {idx}
        else do c.bot += {idx}
    } else  {
        if idx < LEVEL_COLLISION_MAP_SPLIT_AFTER do c.top -= {idx}
        else do c.bot -= {idx}
    }
}

LEVEL_index_collision :: proc(c: ^LEVEL_Collision, x, y: int) -> bool {
    idx := x + y * LEVEL_WIDTH
    if idx < LEVEL_COLLISION_MAP_SPLIT_AFTER do return idx in c.top
    else do return idx in c.bot
}

LEVEL_load_data :: proc(l: ^LEVEL_Collision, fpath: string) {
    data, ok := os.read_entire_file(fpath)
	if !ok {
        log.fatalf("Could not load level from file %s", fpath)
		panic("FATAL: check log for more info")
	}
	defer delete(data)

    x := 0
    y := 0
    for b in data {
        for i in 0..<8 {
            // read bit i
            shift := 7 - u8(i)
            bit := (b >> shift) & 1
            if bit == 1 do LEVEL_set_index_collision(l, x, y, true)
            else do LEVEL_set_index_collision(l, x, y, false)

            x += 1
            if x >= LEVEL_WIDTH {
                x = 0
                y += 1
            }
        }
    }
}

LEVEL_global_draw_random_air_tile :: proc(dest: rl.Rectangle) {
    level_man := &APP_global_app.game.level_manager
    tex := &level_man.air_tile_set.(rl.Texture2D)

    variant := rand.int_max(2)
    src := rl.Rectangle{ 48 * f32(variant), 0, 48, 48}

    rl.DrawTexturePro(tex^, src, dest, FVECTOR_ZERO, 0, rl.WHITE)
}

LEVEL_draw :: proc(collision: ^LEVEL_Collision, hazards: ^[LEVEL_Room_Connection]bool, force_no_hazards: bool = false) {
    for x in 0..<LEVEL_WIDTH {
        for y in 0..<LEVEL_HEIGHT {
            r := LEVEL_get_rect_from_coords(x, y)
            col := LEVEL_TILE_AIR_COLOR
            if LEVEL_index_collision(collision, x, y) {
                rl.DrawRectangleRec(to_rl_rect(r), LEVEL_TILE_WALL_COLOR)
            }
            else {
                LEVEL_global_draw_random_air_tile(to_rl_rect(r))
            }
            
        }
    }

    col := DMG_COLOR
    if force_no_hazards do col = LEVEL_TILE_AIR_COLOR
    for exists, dir in hazards {
        if !exists do continue
        tile_1, tile_2 := LEVEL_get_hazard_tiles(dir)

        if !LEVEL_index_collision(collision, tile_1.x, tile_1.y) do continue

        r1 := LEVEL_get_rect_from_coords(tile_1.x, tile_1.y)
        r2 := LEVEL_get_rect_from_coords(tile_2.x, tile_2.y)

        
        rl.DrawRectangleRec(to_rl_rect(r1), col)
        rl.DrawRectangleRec(to_rl_rect(r2), col)
    }

    rw, rh := APP_get_global_render_size()
    render_rect := rl.Rectangle{0, 0, f32(rw), f32(rh)}
    rl.DrawRectangleRec(render_rect, {0,0,255,30})
}