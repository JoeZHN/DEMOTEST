extends Node
class_name TurnManager

var turn_order: Array[BattleUnit] = []
var current_index: int = -1
var round_index: int = 1

func setup(units: Array[BattleUnit]) -> void:
	turn_order = units.duplicate()
	turn_order.sort_custom(func(a: BattleUnit, b: BattleUnit) -> bool:
		return a.initiative > b.initiative
	)
	current_index = -1
	round_index = 1

func start_first_turn() -> BattleUnit:
	if turn_order.is_empty():
		return null

	current_index = 0
	return turn_order[current_index]

func get_current_unit() -> BattleUnit:
	if turn_order.is_empty():
		return null

	if current_index < 0 or current_index >= turn_order.size():
		return null

	return turn_order[current_index]

func advance_turn() -> BattleUnit:
	if turn_order.is_empty():
		return null

	current_index += 1

	if current_index >= turn_order.size():
		current_index = 0
		round_index += 1

	return turn_order[current_index]

func get_turn_order_debug_text() -> String:
	var parts: Array[String] = []
	for i in range(turn_order.size()):
		var unit := turn_order[i]
		parts.append("%d.%s" % [i + 1, unit.display_name])
	return " | ".join(parts)
