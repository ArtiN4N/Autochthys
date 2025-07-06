package src

import "core:log"
import "core:fmt"
import "core:c/libc"
import "core:mem"

@(require_results)
UTIL_create_tracking_allocator_A :: proc() -> (t_alloc: mem.Tracking_Allocator) {
	default_allocator := context.allocator
	mem.tracking_allocator_init(&t_alloc, default_allocator)

	return
}

UTIL_report_tracking_allocator :: proc(t_alloc: ^mem.Tracking_Allocator) {
	err := false

	if len(t_alloc.allocation_map) > 0 {
		fmt.printfln("\n\n\n== MEMORY LEAKS ==")
	} else {
		fmt.printfln("No memory leaks =)")
	}

	for _, value in t_alloc.allocation_map {
		fmt.printfln("%v: Leaked %v bytes", value.location, value.size)
		err = true
	}

	mem.tracking_allocator_clear(t_alloc)
	when ODIN_OS == .Linux { if err { libc.getchar() } }
}

UTIL_destroy_tracking_allocator_D :: proc(t_alloc: ^mem.Tracking_Allocator) {
	mem.tracking_allocator_destroy(t_alloc)
}

UTIL_check_tracking_allocator :: proc(t_alloc: ^mem.Tracking_Allocator) {
	if len(t_alloc.bad_free_array) > 0 {
		for b in t_alloc.bad_free_array {
			fmt.printfln("Bad free at: %v", b.location)
		}
	
		when ODIN_OS == .Linux { libc.getchar() }
		panic("Bad free detected!")
	}
}