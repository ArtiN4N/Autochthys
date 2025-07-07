package src

MAX_ROT_COUNT :: 8

CONST_Gun_Rotation :: enum {
    Default = 0,
    Eight,
}

CONST_Gun_Rotation_Data :: struct {
    values: [MAX_ROT_COUNT]f32,
    count: int,
}

default_values :: [MAX_ROT_COUNT]f32{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
eight_values   :: [MAX_ROT_COUNT]f32{0.0, 3.14/4.0*1, 3.14/4.0*2, 3.14/4.0*3, 3.14/4.0*4, 3.14/4.0*5, 3.14/4.0*6, 3.14/4.0*7}

DefaultRotation :: CONST_Gun_Rotation_Data{values = default_values, count = 1}
EightRotation   :: CONST_Gun_Rotation_Data{values = eight_values, count = 8}