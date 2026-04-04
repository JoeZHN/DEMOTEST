extends Node
class_name GridManager

var cols: int = 8
var rows: int = 8
var cell_size: int = 96
var origin: Vector2 = Vector2(48, 48)

func setup(grid_data: Dictionary) -> void:
	cols = int(grid_data.get("cols", 8))
	rows = int(grid_data.get("rows", 8))
	cell_size = int(grid_data.get("cell_size", 96))

func is_in_bounds(grid_pos: Vector2i) -> bool:
	return (
		grid_pos.x >= 0 and grid_pos.x < cols
		and grid_pos.y >= 0 and grid_pos.y < rows
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return origin + Vector2(
		grid_pos.x * cell_size,
		grid_pos.y * cell_size
	)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local := world_pos - origin
	return Vector2i(
		roundi(local.x / cell_size),
		roundi(local.y / cell_size)
	)
