extends Node
class_name TurnManager

var turn_order: Array = []
var current_index: int = -1
var round_index: int = 1

func setup(units: Array) -> void:
	turn_order = units.duplicate()
	turn_order.sort_custom(func(a, b) -> bool:
		if a == null:
			return false
		if b == null:
			return true
		return a.initiative > b.initiative
	)
	current_index = -1
	round_index = 1

func start_first_turn():
	if not has_alive_units():
		return null

	current_index = _find_next_alive_index(0)
	if current_index == -1:
		return null

	return turn_order[current_index]

func get_current_unit():
	if turn_order.is_empty():
		return null

	if current_index < 0 or current_index >= turn_order.size():
		return null

	var unit = turn_order[current_index]
	if unit == null or not unit.is_alive:
		return null

	return unit

func advance_turn():
	if not has_alive_units():
		return null

	var start_index: int = current_index + 1
	if start_index >= turn_order.size():
		start_index = 0
		round_index += 1

	var next_index: int = _find_next_alive_index(start_index)
	if next_index == -1:
		return null

	if current_index != -1 and next_index <= current_index:
		if not (current_index == turn_order.size() - 1 and next_index == 0):
			round_index += 1

	current_index = next_index
	return turn_order[current_index]

func has_alive_units() -> bool:
	for unit in turn_order:
		if unit != null and unit.is_alive:
			return true
	return false

func _find_next_alive_index(start_index: int) -> int:
	if turn_order.is_empty():
		return -1

	for offset in range(turn_order.size()):
		var idx: int = (start_index + offset) % turn_order.size()
		var unit = turn_order[idx]
		if unit != null and unit.is_alive:
			return idx

	return -1

func get_turn_order_debug_text() -> String:
	var parts: Array[String] = []
	for i in range(turn_order.size()):
		var unit = turn_order[i]
		if unit == null:
			continue

		var suffix: String = ""
		if not unit.is_alive:
			suffix = "(dead)"

		parts.append("%d.%s%s" % [i + 1, unit.display_name, suffix])

	return " | ".join(parts)
