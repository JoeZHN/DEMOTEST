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

func get_manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func get_cells_in_move_range(center: Vector2i, move_range: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for x in range(cols):
		for y in range(rows):
			var cell := Vector2i(x, y)
			if get_manhattan_distance(center, cell) <= move_range:
				result.append(cell)

	return result

func get_cells_in_attack_range(center: Vector2i, attack_range: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for x in range(cols):
		for y in range(rows):
			var cell := Vector2i(x, y)
			var distance := get_manhattan_distance(center, cell)
			if distance > 0 and distance <= attack_range:
				result.append(cell)

	return result

func get_unit_at_grid(units: Array[BattleUnit], grid_pos: Vector2i) -> BattleUnit:
	for unit in units:
		if unit != null and unit.is_alive and unit.grid_position == grid_pos:
			return unit
	return null
