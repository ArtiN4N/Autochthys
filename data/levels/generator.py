import pygame
import tkinter as tk
from tkinter import simpledialog

# Constants
WINDOW_SIZE = 800
GRID_SIZE = 16
MARGIN = 2

# Calculate cell size considering margins
total_margin = MARGIN * (GRID_SIZE + 1)
cell_size = (WINDOW_SIZE - total_margin) // GRID_SIZE

# Init Pygame
pygame.init()
screen = pygame.display.set_mode((WINDOW_SIZE, WINDOW_SIZE))
pygame.display.set_caption("map editor")

# Colors
BG_COLOR = (30, 30, 30)
CELL_ON = (240, 240, 240)
CELL_OFF = (80, 80, 80)

# Grid state: False = off, True = on
grid = [[False for _ in range(GRID_SIZE)] for _ in range(GRID_SIZE)]

mouse_down = False
mouse_button = None
touched_this_drag = set()

def write_grid_to_file(grid, filename):
    assert len(grid) == 16 and all(len(row) == 16 for row in grid), "Grid must be 16x16"

    bits = []
    for row in grid:
        for val in row:
            bits.append(1 if val else 0)

    # Pack bits into bytes
    byte_data = bytearray()
    for i in range(0, len(bits), 8):
        byte = 0
        for bit in bits[i:i+8]:
            byte = (byte << 1) | bit
        byte_data.append(byte)

    with open(filename, 'wb') as f:
        f.write(byte_data)

def get_cell_from_pos(mx, my):
    grid_x = (mx - MARGIN) // (cell_size + MARGIN)
    grid_y = (my - MARGIN) // (cell_size + MARGIN)
    if 0 <= grid_x < GRID_SIZE and 0 <= grid_y < GRID_SIZE:
        cell_left = MARGIN + grid_x * (cell_size + MARGIN)
        cell_top = MARGIN + grid_y * (cell_size + MARGIN)
        if mx >= cell_left and mx < cell_left + cell_size and my >= cell_top and my < cell_top + cell_size:
            return grid_x, grid_y
    return None

def apply_click(cell, button):
    if cell and cell not in touched_this_drag:
        x, y = cell
        grid[y][x] = True if button == 1 else False  # 1 = left, 3 = right
        touched_this_drag.add(cell)

def get_user_input():
    root = tk.Tk()
    root.withdraw()
    root.geometry('+0+0')
    answer = simpledialog.askstring("Input", "file name: ", parent = root)
    root.destroy()
    return answer

# Main loop
running = True
while running:
    screen.fill(BG_COLOR)

    for y in range(GRID_SIZE):
        for x in range(GRID_SIZE):
            rect_x = MARGIN + x * (cell_size + MARGIN)
            rect_y = MARGIN + y * (cell_size + MARGIN)
            color = CELL_ON if grid[y][x] else CELL_OFF
            pygame.draw.rect(screen, color, (rect_x, rect_y, cell_size, cell_size))

    pygame.display.flip()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        elif event.type == pygame.MOUSEBUTTONDOWN:
            mouse_down = True
            mouse_button = event.button
            touched_this_drag.clear()
            apply_click(get_cell_from_pos(*event.pos), mouse_button)

        elif event.type == pygame.MOUSEBUTTONUP:
            mouse_down = False
            touched_this_drag.clear()

        elif event.type == pygame.MOUSEMOTION and mouse_down:
            apply_click(get_cell_from_pos(*event.pos), mouse_button)

        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_s:
                name = get_user_input()
                if name == None:
                    continue
                write_grid_to_file(grid, f"data/levels/{name}.level")
                



pygame.quit()
