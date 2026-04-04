extends Node
class_name StatsComponent

var max_hp: int = 1
var hp: int = 1
var armor: int = 0
var move_range: int = 0
var max_ap: int = 2
var current_ap: int = 2
var base_damage: int = 1

func setup(data: Dictionary) -> void:
	max_hp = int(data.get("max_hp", 1))
	hp = max_hp
	armor = int(data.get("armor", 0))
	move_range = int(data.get("move_range", 0))
	max_ap = int(data.get("max_ap", 2))
	current_ap = max_ap
	base_damage = int(data.get("base_damage", 1))
