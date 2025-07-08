package src

LEVEL_Room_World_Index :: distinct int
LEVEL_Room_Connection :: enum { North, East, South, West }

LEVEL_WORLD_ROOMS :: 85

// below are some sketches for some precomputed block patterns
//
// block_omega_r
// X-X X
// \ \ \
// X X-X
// \ \ \
// X-X X
//
// block_omega_l
// X X-X
// \ \ \
// X-X-X
// \ \ \
// X X-X
//
// block_snake2
// X-X-X
//     \
// X-X-X
// \    
// X X-X
//
// block_snakeS
// X-X-X
// \    
// X-X-X
//     \
// X X-X
//
// block_snakeNU
// X-X X
// \ \ \ 
// X X X
// \ \ \
// X X-X
//
// block_snakeUN
// X X-X
// \ \ \ 
// X X X
// \ \ \
// X-X X
//
// block_w
// X X X
// \ \ \ 
// X X X
// \ \ \
// X-X-X
//
// block_m
// X-X-X
// \ \ \ 
// X X X
// \ \ \
// X X X
//
// block_ring0
// X-X-X
// \ \ \ 
// X X X
// \ \ \
// X-X-X
//
// block_ringTheta
// X-X-X
// \   \ 
// X-X-X
// \   \
// X-X-X
//
// block_yinyang
// X-X X
// \ \ \ 
// X-X-X
// \ \ \
// X X-X
//
// block_doubleS
// X-X-X
// \ \  
// X-X-X
//   \ \
// X-X-X
//
// block_disjointD
// X-X-X
// \   \
// X-X X
//     \
// X-X-X
//
// block_disjointU
// X-X-X
// \   \
// X X-X
// \   
// X-X-X
//

// level rooms can be organized into blocks
// blocks describe a 3x3 pattern of rooms and how they link to one another
// block[n][x] is the link array for the xth room in the block (x / 9)
// block[n][x][y] is the link between room x and y, 1 for linked, 0 for not
@(rodata)
LEVEL_precomputed_room_blocks: [][9][9]u8 = {
    {
        // block_dense
        // X-X-X
        // \ \ \
        // X-X-X
        // \ \ \
        // X-X-X
        { 0, 1, 0, 1, 0, 0, 0, 0, 0 },
        { 1, 0, 1, 0, 1, 0, 0, 0, 0 },
        { 0, 1, 0, 0, 0, 1, 0, 0, 0 },
        { 1, 0, 0, 0, 1, 0, 0, 0, 0 },
        { 0, 1, 0, 1, 0, 1, 0, 0, 0 },
        { 0, 0, 1, 0, 1, 0, 0, 0, 0 },
        { 0, 0, 0, 1, 0, 0, 0, 1, 0 },
        { 0, 0, 0, 0, 1, 0, 1, 0, 1 },
        { 0, 0, 0, 0, 0, 1, 0, 1, 0 },
    }
}