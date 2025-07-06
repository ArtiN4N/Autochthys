# Level Formatting
All levels are 16x16. The first 16 lines contains 16 characters each. "#" represents a collidable wall, and "." represents non-collidable air.
The next line contains 2 comma seperated numbers, the x and y tile index of the debug spawn point. This spawn point is used when no spawn point is specified on loading into the level
Levels can be passive or aggresive. Passive levels contains no combat. Aggressive levels contain combat. The next line contains a single number, which signals whether the level is passive or aggresive. 0 for passive, 1 for aggresive

## Aggressive levels
The next line is the number of enemies there are, or n.
The next n lines contain three comma seperated numbers -- the enemy id, which is mapped to a specific enemy type via "CONST_Ship_Type" found in src/CONST_ship.odin, and then the x and y tile index that the enemy should spawn on