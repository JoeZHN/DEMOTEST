extends RefCounted
class_name BattleAI

static func get_attack_range_for_unit(unit: BattleUnit) -> int:
	if unit == null:
		return 1

	if unit.job == "archer" or unit.job == "raider_archer":
		return 3

	return 1

static func find_nearest_player_unit(enemy_unit: BattleUnit, units: Array[BattleUnit], grid_manager: GridManager) -> BattleUnit:
	var nearest_unit: BattleUnit = null
	var nearest_distance: int = 999999

	for unit in units:
		if unit == null:
			continue
		if not unit.is_alive:
			continue
		if unit.camp != BattleConstants.CAMP_PLAYER:
			continue

		var distance: int = grid_manager.get_manhattan_distance(enemy_unit.grid_position, unit.grid_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_unit = unit

	return nearest_unit

static func can_attack_target(attacker: BattleUnit, target: BattleUnit, grid_manager: GridManager) -> bool:
	if attacker == null or target == null:
		return false
	if not attacker.is_alive or not target.is_alive:
		return false

	var attack_range: int = get_attack_range_for_unit(attacker)
	var distance: int = grid_manager.get_manhattan_distance(attacker.grid_position, target.grid_position)
	return distance > 0 and distance <= attack_range

static func find_best_move_cell_toward_target(
	enemy_unit: BattleUnit,
	target_unit: BattleUnit,
	units: Array[BattleUnit],
	grid_manager: GridManager
) -> Vector2i:
	if enemy_unit == null or target_unit == null:
		return enemy_unit.grid_position

	var candidate_cells: Array[Vector2i] = grid_manager.get_cells_in_move_range(
		enemy_unit.grid_position,
		enemy_unit.stats.move_range
	)

	var best_cell: Vector2i = enemy_unit.grid_position
	var best_distance: int = grid_manager.get_manhattan_distance(enemy_unit.grid_position, target_unit.grid_position)

	for cell in candidate_cells:
		var occupant: BattleUnit = grid_manager.get_unit_at_grid(units, cell)
		if occupant != null and occupant != enemy_unit:
			continue

		var distance: int = grid_manager.get_manhattan_distance(cell, target_unit.grid_position)
		if distance < best_distance:
			best_distance = distance
			best_cell = cell

	return best_cell
