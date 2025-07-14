package src

import "core:math"
import rl "vendor:raylib"

UTIL_rotate_point :: proc(pos: FVector, angle: f32) -> FVector {
    cos_a := math.cos(angle)
    sin_a := math.sin(angle)
    return FVector{pos.x * cos_a - pos.y * sin_a, pos.x * sin_a + pos.y * cos_a}
}

UTIL_rotate_rectangle :: proc(rect: rl.Rectangle, center: FVector, angle: f32) -> rl.Rectangle {
    rot_angle := -(angle - (math.PI / 2.0));;
    
    cos_a := math.cos(rot_angle);
    sin_a := math.sin(rot_angle);

    corners := [4]FVector{
        FVector{rect.x, rect.y},                               
        FVector{rect.x + rect.width, rect.y},                  
        FVector{rect.x + rect.width, rect.y + rect.height},    
        FVector{rect.x, rect.y + rect.height},                 
    };

    rotated := [4]FVector{};
    for i in 0..=3 {
        offset := corners[i] - center;
        rotated[i] = center + FVector{
            offset.x * cos_a - offset.y * sin_a,
            offset.x * sin_a + offset.y * cos_a,
        };
    }

    min_x := rotated[0].x;
    max_x := rotated[0].x;
    min_y := rotated[0].y;
    max_y := rotated[0].y;

    for i in 1..=3 {
        min_x = math.min(min_x, rotated[i].x);
        max_x = math.max(max_x, rotated[i].x);
        min_y = math.min(min_y, rotated[i].y);
        max_y = math.max(max_y, rotated[i].y);
    }

    return rl.Rectangle{
        x = min_x,
        y = min_y,
        width = max_x - min_x,
        height = max_y - min_y,
    };
}

