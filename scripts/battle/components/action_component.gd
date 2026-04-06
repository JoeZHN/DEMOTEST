extends Node
class_name ActionComponent

var has_moved_this_turn: bool = false
var has_acted_this_turn: bool = false

func reset_for_new_turn(max_ap: int) -> void:
	has_moved_this_turn = false
	has_acted_this_turn = false

func can_move(current_ap: int) -> bool:
	return not has_moved_this_turn

func can_attack(current_ap: int) -> bool:
	return current_ap >= 1

func mark_moved() -> void:
	has_moved_this_turn = true

func mark_acted() -> void:
	has_acted_this_turn = true
