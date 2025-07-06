package src

import os "core:os"
import log "core:log"
import strings "core:strings"

LEVEL_load_data :: proc(fpath: string) -> Level {
    ret: Level

    data, ok := os.read_entire_file(fpath)
	if !ok {
        log.fatalf("Could not load level from file %s", fpath)
		panic("FATAL: check log for more info")
	}
	defer delete(data)


    // the first LEVEL_HEIGHT lines contain LEVEL_WIDTH characters
    // # means a wall, . means air
    it := string(data)
    x, y := 0, 0
	for line in strings.split_lines_iterator(&it) {
        x = 0
		for c in line {
            collision := false
            if c == '#' do collision = true
            ret.collision_map[x][y] = collision

            x += 1
        }
        y += 1
	}

    return  ret
}