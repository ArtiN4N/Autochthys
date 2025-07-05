package src

import "core:math"

UTIL_rotate_point :: proc(pos: FVector, angle: f32) -> FVector {
    cos_a := math.cos(angle)
    sin_a := math.sin(angle)
    return FVector{pos.x * cos_a - pos.y * sin_a, pos.x * sin_a + pos.y * cos_a}
}