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

    variant := rand.int_max(3)
    src := rl.Rectangle{ 48 * f32(variant), 0, 48, 48}

    rl.DrawTexturePro(tex^, src, dest, FVECTOR_ZERO, 0, rl.WHITE)
}

LEVEL_adj_to_tile_variant :: proc(adj_matrix: [3][3]bool) -> uint {
    s1 := adj_matrix[0]
    s2 := adj_matrix[1]
    s3 := adj_matrix[2]

    if !s1[1] && s2 == {false, true, false} &&  s3[1] do return 0
    else if !s1[1] && s2 == {true, true, false}  && !s3[1] do return 1
    else if  s1[1] && s2 == {false, true, false}   && !s3[1] do return 2
    else if !s1[1] && s2 == {false, true, true}  && !s3[1] do return 3
    else if !s1[1] && s2 == {true, true, true}   && !s3[1] do return 4
    else if  s1[1] && s2 == {false, true, false} &&  s3[1] do return 5

    else if !s1[1] && s2 == {true, true, true} && s3 == {true, true, true}   do return 6
    else if !s1[1] && s2 == {true, true, true} && s3 == {true, true, false}  do return 7
    else if !s1[1] && s2 == {true, true, true} && s3 == {false, true, true}  do return 8
    else if !s1[1] && s2 == {true, true, true} && s3 == {false, true, false} do return 9

    else if  s1[0] && s1[1] && s2 == {true, true, false} &&  s3[0] && s3[1] do return 10
    else if  s1[0] && s1[1] && s2 == {true, true, false} && !s3[0] && s3[1] do return 11
    else if !s1[0] && s1[1] && s2 == {true, true, false} &&  s3[0] && s3[1] do return 12
    else if !s1[0] && s1[1] && s2 == {true, true, false} && !s3[0] && s3[1] do return 13

    else if s1 == {true, true, true}   && s2 == {true, true, true} && !s3[1] do return 14
    else if s1 == {false, true, true}  && s2 == {true, true, true} && !s3[1] do return 15
    else if s1 == {true, true, false}  && s2 == {true, true, true} && !s3[1] do return 16
    else if s1 == {false, true, false} && s2 == {true, true, true} && !s3[1] do return 17

    else if s1[1] && s1[2]  && s2 == {false, true, true} && s3[1] && s3[2]  do return 18
    else if s1[1] && !s1[2] && s2 == {false, true, true} && s3[1] && s3[2]  do return 19
    else if s1[1] && s1[2]  && s2 == {false, true, true} && s3[1] && !s3[2] do return 20
    else if s1[1] && !s1[2] && s2 == {false, true, true} && s3[1] && !s3[2] do return 21

    else if s1[1] &&  s1[2] && s2 == {false, true, true} && !s3[1] do return 22
    else if s1[1] && !s1[2] && s2 == {false, true, true} && !s3[1] do return 26

    else if !s1[1] && s2 == {false, true, true} && s3[1] &&  s3[2] do return 23
    else if !s1[1] && s2 == {false, true, true} && s3[1] && !s3[2] do return 27

    else if !s1[1] && s2 == {true, true, false} &&  s3[0] && s3[1] do return 24
    else if !s1[1] && s2 == {true, true, false} && !s3[0] && s3[1] do return 28

    else if  s1[0] && s1[1] && s2 == {true, true, false} && !s3[1] do return 25
    else if !s1[0] && s1[1] && s2 == {true, true, false} && !s3[1] do return 29

    else if !s1[1] && s2 == {false, true, false} && !s3[1] do return 30

    else if s1 == {true, true, true}  && s2 == {true, true, true} && s3 == {true, true, true}  do return 31
    else if s1 == {true, true, false} && s2 == {true, true, true} && s3 == {true, true, true}  do return 32
    else if s1 == {true, true, true}  && s2 == {true, true, true} && s3 == {true, true, false} do return 33
    else if s1 == {true, true, true}  && s2 == {true, true, true} && s3 == {false, true, true} do return 34
    else if s1 == {false, true, true} && s2 == {true, true, true} && s3 == {true, true, true}  do return 35

    else if s1 == {false, true, false} && s2 == {true, true, true} && s3 == {false, true, false}  do return 36

    else if s1 == {false, true, false} && s2 == {true, true, true} && s3 == {true, true, true}  do return 37
    else if s1 == {true, true, false} && s2 == {true, true, true} && s3 == {true, true, false}  do return 38
    else if s1 == {true, true, true} && s2 == {true, true, true} && s3 == {false, true, false}  do return 39
    else if s1 == {false, true, true} && s2 == {true, true, true} && s3 == {false, true, true}  do return 40

    else if s1 == {false, true, false} && s2 == {true, true, true} && s3 == {false, true, true}  do return 41
    else if s1 == {false, true, false} && s2 == {true, true, true} && s3 == {true, true, false}  do return 42
    else if s1 == {true, true, false} && s2 == {true, true, true} && s3 == {false, true, false}  do return 43
    else if s1 == {false, true, true} && s2 == {true, true, true} && s3 == {false, true, false}  do return 44

    log.warn("Got unidentified tile texture")
    return 999
}

LEVEL_get_wall_tile_variant :: proc(collision: ^LEVEL_Collision, x, y: int, adj_matrix: ^[3][3]bool) -> uint {
    adj_matrix[1][1] = true
    for y_off in -1..=1 {
        for x_off in -1..=1 {
            check_x := x + x_off
            check_y := y + y_off

            man_set := false
            man_set |= check_x < 0
            man_set |= check_x >= LEVEL_WIDTH 
            man_set |= check_y < 0
            man_set |= check_y >= LEVEL_HEIGHT

            if !man_set {
                adj_matrix[y_off + 1][x_off + 1] = LEVEL_index_collision(collision, check_x, check_y)
            }
            else do adj_matrix[y_off + 1][x_off + 1] = true
        }
    }

    return LEVEL_adj_to_tile_variant(adj_matrix^)
}


LEVEL_global_draw_wall_tile :: proc(dest: rl.Rectangle, collision: ^LEVEL_Collision, x, y: int) {
    level_man := &APP_global_app.game.level_manager
    tex := &level_man.wall_tile_set.(rl.Texture2D)

    adj_matrix := [3][3]bool{}
    variant := LEVEL_get_wall_tile_variant(collision, x, y, &adj_matrix)

    src := rl.Rectangle{ 48 * f32(variant), 0, 48, 48}

    rl.DrawTexturePro(tex^, src, dest, FVECTOR_ZERO, 0, rl.WHITE)
}

LEVEL_draw :: proc(collision: ^LEVEL_Collision, hazards: ^[LEVEL_Room_Connection]bool, force_no_hazards: bool = false) {
    for x in 0..<LEVEL_WIDTH {
        for y in 0..<LEVEL_HEIGHT {
            r := LEVEL_get_rect_from_coords(x, y)
            col := LEVEL_TILE_AIR_COLOR
            if LEVEL_index_collision(collision, x, y) {
                //rl.DrawRectangleRec(to_rl_rect(r), LEVEL_TILE_WALL_COLOR)
                LEVEL_global_draw_wall_tile(to_rl_rect(r), collision, x, y)
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
}