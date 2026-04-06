extends Node2D
class_name TileOverlay

var grid_manager: GridManager
var move_cells: Array[Vector2i] = []
var attack_cells: Array[Vector2i] = []
var selected_cell: Vector2i = Vector2i(-999, -999)

func setup(new_grid_manager: GridManager) -> void:
	grid_manager = new_grid_manager
	queue_redraw()

func set_move_cells(cells: Array[Vector2i]) -> void:
	move_cells = cells.duplicate()
	queue_redraw()

func set_attack_cells(cells: Array[Vector2i]) -> void:
	attack_cells = cells.duplicate()
	queue_redraw()

func set_selected_cell(cell: Vector2i) -> void:
	selected_cell = cell
	queue_redraw()

func clear_all() -> void:
	move_cells.clear()
	attack_cells.clear()
	selected_cell = Vector2i(-999, -999)
	queue_redraw()

func _draw() -> void:
	if grid_manager == null:
		return

	for cell in move_cells:
		_draw_cell_fill(cell, Color(0.2, 0.5, 0.9, 0.25))

	for cell in attack_cells:
		_draw_cell_fill(cell, Color(0.9, 0.3, 0.3, 0.25))

	if selected_cell.x >= 0 and selected_cell.y >= 0:
		_draw_cell_outline(selected_cell, Color(1.0, 1.0, 0.4, 1.0), 3.0)

func _draw_cell_fill(cell: Vector2i, color: Color) -> void:
	var top_left: Vector2 = grid_manager.grid_to_world(cell)
	draw_rect(
		Rect2(top_left, Vector2(grid_manager.cell_size, grid_manager.cell_size)),
		color,
		true
	)

func _draw_cell_outline(cell: Vector2i, color: Color, width: float) -> void:
	var top_left: Vector2 = grid_manager.grid_to_world(cell)
	draw_rect(
		Rect2(top_left, Vector2(grid_manager.cell_size, grid_manager.cell_size)),
		color,
		false,
		width
	)
