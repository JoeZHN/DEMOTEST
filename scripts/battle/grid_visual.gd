extends Node2D

var cols: int = 8
var rows: int = 8
var cell_size: int = 96
var origin: Vector2 = Vector2(96, 96)

func setup(new_cols: int, new_rows: int, new_cell_size: int, new_origin: Vector2) -> void:
	cols = new_cols
	rows = new_rows
	cell_size = new_cell_size
	origin = new_origin
	queue_redraw()

func _draw() -> void:
	for x in range(cols + 1):
		var from := origin + Vector2(x * cell_size, 0)
		var to := origin + Vector2(x * cell_size, rows * cell_size)
		draw_line(from, to, Color(0.45, 0.45, 0.45, 1.0), 1.0)

	for y in range(rows + 1):
		var from := origin + Vector2(0, y * cell_size)
		var to := origin + Vector2(cols * cell_size, y * cell_size)
		draw_line(from, to, Color(0.45, 0.45, 0.45, 1.0), 1.0)
